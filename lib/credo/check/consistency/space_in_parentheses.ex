defmodule Credo.Check.Consistency.SpaceInParentheses do
  @moduledoc """
  Don't use spaces after `(`, `[`, and `{` or before `}`, `]`, and `)`. This is the **preferred** way, although other styles are possible, as long as it is applied consistently.

      # preferred way
      Helper.format({1, true, 2}, :my_atom)

      # also okay
      Helper.format( { 1, true, 2 }, :my_atom )

  While this is not necessarily a concern for the correctness of your code,
  you should use a consistent style throughout your codebase.
  """

  @explanation [check: @moduledoc]
  @code_patterns [
    Credo.Check.Consistency.SpaceInParentheses.WithSpace,
    Credo.Check.Consistency.SpaceInParentheses.WithoutSpace
  ]

  alias Credo.Check.Consistency.Helper
  alias Credo.Check.PropertyValue

  use Credo.Check, run_on_all: true, base_priority: :high

  @doc false
  def run(source_files, params \\ []) when is_list(source_files) do
    source_files
    |> Helper.run_code_patterns(@code_patterns, params)
    |> Helper.add_issues_to_source_files(&issue_for/5, params)
  end

  defp issue_for(_issue_meta, _actual_props, nil, _picked_count, _total_count), do: nil
  defp issue_for(_issue_meta, [], _expected_prop, _picked_count, _total_count), do: nil
  defp issue_for(issue_meta, actual_prop, expected_prop, _picked_count, _total_count) do
    line_no = PropertyValue.meta(actual_prop, :line_no)
    actual_prop = PropertyValue.get(actual_prop)
    format_issue issue_meta,
      message: message_for(actual_prop, expected_prop),
      line_no: line_no
  end

  defp message_for(:with_space, :without_space) do
    "There is whitespace around parentheses/brackets and it's not consistent with other code in the project."
  end
  defp message_for(:without_space, :with_space) do
    "No whitespace around parentheses/brackets and it's not consistent with other code in the project."
  end
end
