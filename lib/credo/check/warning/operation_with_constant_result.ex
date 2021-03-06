defmodule Credo.Check.Warning.OperationWithConstantResult do
  @moduledoc """
  Operations on the same values always yield the same result and therefore make
  little sense in production code.

  Examples:

      y / 1   # always returns y
      x * 1   # always returns x
      x * 0   # always returns 0

  In pratice they are likely the result of a debugging session or were made by
  mistake.
  """

  @explanation [check: @moduledoc]
  @ops_and_constant_results [
      {:/, "the left side of the expression", 1},
      {:*, "zero", 0},
      {:*, "the left side of the expression", 1}
    ]

  use Credo.Check, base_priority: :high

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.traverse(source_file, &traverse(&1, &2, issue_meta))
  end

  # skip references to functions
  defp traverse({:&, _, _}, issues, _) do
    {nil, issues}
  end
  for {op, constant_result, operand} <- @ops_and_constant_results do
    defp traverse({unquote(op), meta, [_lhs, unquote(operand)]} = ast, issues, issue_meta) do
      new_issue = issue_for(meta[:line], unquote(op), unquote(constant_result), issue_meta)
      {ast, issues ++ [new_issue]}
    end
  end
  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end


  defp issue_for(line_no, trigger, constant_result, issue_meta) do
    format_issue issue_meta,
      message: "Operation will always return #{constant_result}.",
      trigger: trigger,
      line_no: line_no
  end
end
