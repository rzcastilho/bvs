defmodule BVS.Parser do
  def parse(file) do
    return_codes =
      BVS.Negativation.list_return_codes()
      |> Enum.map(&{&1.code, &1.id})
      |> Enum.into(%{})

    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&sanitize_data/1)
    |> Stream.filter(&ignore_types(&1, [:header, :trailler]))
    |> Stream.map(&to_insertion/1)
    |> Stream.map(&translate_return_codes(&1, return_codes))
    |> Enum.to_list()
  end

  # HEADER RETORNO
  defp parse_line(
         <<cliente::binary-size(8), "0000000000", data::binary-size(6), "RETORNO",
           informante::binary-size(55), controle::binary-size(8), "        ",
           versao::binary-size(2), _brancos::binary-size(126), cod_retorno::binary-size(2)>>
       ) do
    %{
      "tipo" => :header,
      "cliente" => cliente,
      "data" => data,
      "informante" => informante,
      "controle" => controle,
      "versao" => versao,
      "cod_retorno" => cod_retorno
    }
  end

  # NOME
  defp parse_line(<<
         cliente::binary-size(8),
         "1",
         sequencia::binary-size(5),
         sistema::binary-size(1),
         "A",
         "10",
         documento_primario::binary-size(20),
         documento_secundario::binary-size(20),
         documento_terciario::binary-size(20),
         nome::binary-size(50),
         _brancos1::binary-size(6),
         data::binary-size(8),
         nome_conjuge::binary-size(40),
         _brancos2::binary-size(16),
         _zeros::binary-size(6),
         naturalidade::binary-size(20),
         estado::binary-size(2),
         _brancos3::binary-size(4),
         cod_retorno::binary-size(2)
       >>) do
    %{
      "tipo" => :name,
      "cliente" => cliente,
      "sequencia" => sequencia,
      "sistema" => sistema,
      "documento_primario" => documento_primario,
      "documento_secundario" => documento_secundario,
      "documento_terciario" => documento_terciario,
      "nome" => nome,
      "data" => data,
      "nome_conjuge" => nome_conjuge,
      "naturalidade" => naturalidade,
      "estado" => estado,
      "cod_retorno" => cod_retorno
    }
  end

  # ENDEREÇO
  defp parse_line(<<
         cliente::binary-size(8),
         "1",
         sequencia::binary-size(5),
         sistema::binary-size(1),
         "B",
         "10",
         documento_principal::binary-size(20),
         tipo_registro::binary-size(1),
         endereco::binary-size(50),
         bairro::binary-size(20),
         cep::binary-size(8),
         cidade::binary-size(20),
         uf::binary-size(2),
         telefone::binary-size(20),
         _brancos::binary-size(71),
         cod_retorno::binary-size(2)
       >>) do
    %{
      "tipo" => :address,
      "cliente" => cliente,
      "sequencia" => sequencia,
      "sistema" => sistema,
      "documento_principal" => documento_principal,
      "tipo_registro" => tipo_registro,
      "endereco" => endereco,
      "bairro" => bairro,
      "cep" => cep,
      "cidade" => cidade,
      "uf" => uf,
      "telefone" => telefone,
      "cod_retorno" => cod_retorno
    }
  end

  # OCORRENCIA DO SCPC E SCPCE
  defp parse_line(<<
         cliente::binary-size(8),
         "1",
         sequencia::binary-size(5),
         "1",
         "1",
         operacao::binary-size(2),
         documento_principal::binary-size(20),
         data::binary-size(8),
         ocorrencia::binary-size(2),
         contrato::binary-size(22),
         avalista::binary-size(20),
         valor_debito::binary-size(11),
         documento_debito::binary-size(2),
         _brancos1::binary-size(17),
         "N",
         "00",
         opcao_boleto_devedor::binary-size(1),
         opcao_boleto_avalista::binary-size(1),
         data_vencimento::binary-size(8),
         valor_cobranca::binary-size(11),
         motivo_reabilitacao::binary-size(4),
         _brancos2::binary-size(67),
         _brancos3::binary-size(15),
         cod_retorno::binary-size(2)
       >>) do
    %{
      "tipo" => :ocurrence,
      "cliente" => cliente,
      "sequencia" => sequencia,
      "operacao" => operacao,
      "documento_principal" => documento_principal,
      "data" => data,
      "ocorrencia" => ocorrencia,
      "contrato" => contrato,
      "avalista" => avalista,
      "valor_debito" => valor_debito,
      "documento_debito" => documento_debito,
      "opcao_boleto_devedor" => opcao_boleto_devedor,
      "opcao_boleto_avalista" => opcao_boleto_avalista,
      "data_vencimento" => data_vencimento,
      "valor_cobranca" => valor_cobranca,
      "motivo_reabilitacao" => motivo_reabilitacao,
      "cod_retorno" => cod_retorno
    }
  end

  # TRAILLER
  defp parse_line(
         <<cliente::binary-size(8), "9999999999", data::binary-size(6),
           _brancos::binary-size(206), cod_retorno::binary-size(2)>>
       ) do
    %{
      "tipo" => :trailler,
      "cliente" => cliente,
      "data" => data,
      "cod_retorno" => cod_retorno
    }
  end

  defp parse_line(line), do: line

  def filter_error(%{"cod_retorno" => cod_retorno}) when cod_retorno != "00", do: true

  def filter_error(_), do: false

  def ignore_types(%{"tipo" => tipo}, ignore_list) do
    tipo not in ignore_list
  end

  def to_insertion(
        %{
          "tipo" => :name,
          "sequencia" => sequence,
          "documento_primario" => doc,
          "cod_retorno" => return_code
        } = details
      ) do
    [{document_type, document}] = Enum.to_list(doc)

    %{
      type: :name,
      sequence: sequence,
      document_type: String.to_atom(document_type),
      document: document,
      return_code_id: return_code,
      details:
        details
        |> Map.delete("tipo")
        |> Map.delete("sequencia")
        |> Map.delete("cod_retorno")
        |> Map.delete("documento_primario")
    }
  end

  def to_insertion(
        %{
          "tipo" => type,
          "sequencia" => sequence,
          "documento_principal" => doc,
          "cod_retorno" => return_code
        } = details
      ) do
    [{document_type, document}] = Enum.to_list(doc)

    %{
      type: type,
      sequence: sequence,
      document_type: String.to_atom(document_type),
      document: document,
      return_code_id: return_code,
      details:
        details
        |> Map.delete("tipo")
        |> Map.delete("sequencia")
        |> Map.delete("cod_retorno")
        |> Map.delete("documento_principal")
    }
  end

  def to_insertion(data), do: data

  def translate_return_codes(%{return_code_id: code} = item, return_codes) do
    Map.put(item, :return_code_id, Map.get(return_codes, code))
  end

  def sanitize_data(data) when is_map(data) do
    data
    |> Map.to_list()
    |> Enum.map(&sanitize_field/1)
    |> Enum.filter(&filter_empty/1)
    |> Enum.into(%{})
  end

  def sanitize_data(data), do: data

  def sanitize_field({"operacao", "10"}), do: {"operacao", :inclusao}
  def sanitize_field({"operacao", "20"}), do: {"operacao", :exclusao}

  def sanitize_field({key, document})
      when key in ~w(documento_principal documento_primario documento_secundario documento_terciario) do
    {
      key,
      case document do
        "CPF" <> value -> %{"cpf" => String.trim(value)}
        "RG" <> value -> %{"rg" => String.trim(value)}
        "     " <> _value -> nil
      end
    }
  end

  def sanitize_field({"sequencia", value}), do: {"sequencia", String.to_integer(value)}

  def sanitize_field({key, field}) when is_binary(field) do
    {
      key,
      String.trim(field)
    }
  end

  def sanitize_field(field), do: field

  def filter_empty({_key, ""}), do: false
  def filter_empty(_field), do: true
end
