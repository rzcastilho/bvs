defmodule BVS do
  @moduledoc """
  BVS keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def test() do
    parse("priv/OT_202406100700080300_negativation_file_RETORNO.txt")
  end

  def parse(file) do
    file
    |> File.read!()
    |> String.split("\r\n")
    |> Enum.map(&parse_line/1)
  end

  # HEADER RETORNO
  defp parse_line(
         <<cliente::binary-size(8), "0000000000", data::binary-size(6), "RETORNO",
           informante::binary-size(55), controle::binary-size(8), "        ",
           versao::binary-size(2), _brancos::binary-size(126), cod_retorno::binary-size(2)>>
       ) do
    %{
      tipo: :header,
      cliente: cliente,
      data: data,
      informante: informante,
      controle: controle,
      versao: versao,
      cod_retorno: cod_retorno
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
      tipo: :nome,
      cliente: cliente,
      sequencia: sequencia,
      sistema: sistema,
      documento_primario: documento_primario,
      documento_secundario: documento_secundario,
      documento_terciario: documento_terciario,
      nome: nome,
      data: data,
      nome_conjuge: nome_conjuge,
      naturalidade: naturalidade,
      estado: estado,
      cod_retorno: cod_retorno
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
      tipo: :endereco,
      cliente: cliente,
      sequencia: sequencia,
      sistema: sistema,
      documento_principal: documento_principal,
      tipo_registro: tipo_registro,
      endereco: endereco,
      bairro: bairro,
      cep: cep,
      cidade: cidade,
      uf: uf,
      telefone: telefone,
      cod_retorno: cod_retorno
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
      tipo: :ocorrencia_scpc_scpce,
      cliente: cliente,
      sequencia: sequencia,
      operacao: operacao,
      documento_principal: documento_principal,
      data: data,
      ocorrencia: ocorrencia,
      contrato: contrato,
      avalista: avalista,
      valor_debito: valor_debito,
      documento_debito: documento_debito,
      opcao_boleto_devedor: opcao_boleto_devedor,
      opcao_boleto_avalista: opcao_boleto_avalista,
      data_vencimento: data_vencimento,
      valor_cobranca: valor_cobranca,
      motivo_reabilitacao: motivo_reabilitacao,
      cod_retorno: cod_retorno
    }
  end

  # TRAILLER
  defp parse_line(
         <<cliente::binary-size(8), "9999999999", data::binary-size(6),
           _brancos::binary-size(206), cod_retorno::binary-size(2)>>
       ) do
    %{
      tipo: :header,
      cliente: cliente,
      data: data,
      cod_retorno: cod_retorno
    }
  end

  defp parse_line(line), do: line
end
