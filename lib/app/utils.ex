defmodule App.Utils do
  def format_gender(gender) do
    case gender do
      :male -> "Masculino"
      :female -> "Feminino"
      :non_binary -> "Não binário"
      :other -> "Outro"
      :prefer_not_to_say -> "Prefiro não dizer"
    end
  end

  def format_birthday(birthday) do
    case birthday do
      nil ->
        "Desconhecido"

      value ->
        formatted_date = Date.to_string(value)
        [year, month, day] = String.split(formatted_date, "-")
        "#{day}/#{month}/#{year}"
    end
  end

  def which_month(date) do
    case date do
      1 -> "Janeiro"
      2 -> "Fevereiro"
      3 -> "Março"
      4 -> "Abril"
      5 -> "Maio"
      6 -> "Junho"
      7 -> "Julho"
      8 -> "Agosto"
      9 -> "Setembro"
      10 -> "Outubro"
      11 -> "Novembro"
      12 -> "Dezembro"
      nil -> nil
      _ -> "N/A"
    end
  end

  def format_process(process) do
    case process do
      :adicao_categoria_b -> "Adição de Categoria B"
      :aula_extra -> "Aula Extra"
      :curso_teorico -> "Curso Teórico"
      :primeira_habilitacao_a -> "Primeira Habilitação A"
      :primeira_habilitacao_b -> "Primeira Habilitação B"
      :primeira_habilitacao_ab -> "Primeira Habilitação AB"
      :reabilitacao -> "Reabilitação"
      :reciclagem -> "Reciclagem"
      :repetencia_a -> "Repetência A"
      :repetencia_b -> "Repetência B"
      :repetencia_ab -> "Repetência AB"
      :repetencia_teorica -> "Repetência Teórica"
      :renovacao_cnh -> "Renovação CNH"
      :outro -> "Outro"
      _ -> "N/A"
    end
  end

  def format_payment(payment) do
    case payment do
      :boleto -> "Boleto"
      :credito -> "Crédito"
      :debito -> "Débito"
      :dinheiro -> "Dinheiro"
      :pix -> "Pix"
      :promissoria -> "Promissória"
      _ -> "N/A"
    end
  end

  def format_payment_status(status) do
    case status do
      true -> "Pago"
      false -> "Pendente"
    end
  end

  def formated_date(birthday) do
    case birthday do
      nil ->
        "Desconhecido"

      value ->
        formatted_date = Date.to_string(value)
        [year, month, day] = String.split(formatted_date, "-")
        "#{day}/#{month}/#{year}"
    end
  end

  def format_installment(installment) do
    case installment do
      nil -> "Não há parcelas em aberto"
      0 -> "Não existe parcelamento"
      1 -> "À vista"
      value -> "#{value}x"
    end
  end
end
