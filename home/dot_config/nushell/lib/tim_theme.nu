use colors.nu tw
use colors.nu gruvbox

# Colors are defined as records with the following three optional fields:
# - fg: foreground color
# - bg: background color
# - attr: attributes (e.g., bold, underline, etc.)
#
# Example: { fg: "#aa0000", bg: "#444444", attr: b }
#
# Attributes can be:
# - l: blink
# - b: bold
# - d: dimmed
# - h: hidden
# - i: italic
# - s: strikethrough
# - u: underline
# - n: no attributes (reset)
# (defaults to no attributes if not specified)
#
# We can access the tailwind color palette using the `tw` function (takes color 
# name and shade as arguments) and the gruvbox color palette using the `gruvbox`
# function (takes color name as argument).

export def main [] {
  {
    # foreground: keep default from terminal
    # background: keep default from terminal
    # cursor: keep default from terminal

    # shape_*: Applies syntax highlighting based on the "shape" (inferred or declared type) of an
    # element on the commandline. Nushell's parser can identify shapes based on many criteria, often
    # as the commandline is being typed.

    # shape_string: Can appear as a single-or-quoted value, a bareword string, the key of a record,
    # an argument which has been declared as a string, and other parsed strings.
    shape_string: { fg: (gruvbox neutral_yellow) }

    # shape_string_interpolation: A single-or-double-quoted string interpolation. This style
    # applies to the dollar sign and quotes of the string. The elements inside the string are
    # styled according to their own shape.
    shape_string_interpolation: { fg: (gruvbox bright_yellow) }

    # shape_raw_string: a raw string literal. E.g., r#'This is a raw string'#. This style applies
    # to the entire raw string.
    shape_raw_string: { fg: (gruvbox faded_yellow) attr: 'i' }

    # shape_record: A record-literal. This style applies to the brackets around the record. The keys
    # and values will be styled according to their individual shapes.
    shape_record: { fg: (gruvbox fg3) }

    # shape_list: A list-literal. This style applies to the brackets and list separator only. The
    # items in a list are styled according to their individual shapes.
    shape_list: { fg: (gruvbox fg3) }

    # shape_table: A table-literl. Color applies to the brackets, semicolon, and list separators. The
    # items in the table are style according to their individual shapes.
    shape_table: { fg: (gruvbox fg3) }

    # shape_bool: A boolean-literal `true` or `false` value
    shape_bool: { fg: (gruvbox neutral_purple) attr: 'b' }

    # shape_int: Integer literals
    shape_int: { fg: (gruvbox neutral_purple) }

    # shape_float: Float literals. E.g., 5.4
    # Also integer literals in a float-argument position
    shape_float: { fg: (gruvbox neutral_purple) attr: 'i' }

    # shape_range: Range literals
    shape_range: { fg: (gruvbox faded_purple) }

    # shape_binary: Binary literals
    shape_binary: { fg: (gruvbox neutral_purple) }

    # shape_datetime: Datetime literals
    shape_datetime: { fg: (gruvbox faded_purple) attr: 'i' }

    # shape_custom: A custom value, usually from a plugin
    shape_custom: { fg: (gruvbox bright_purple) }

    # shape_nothing: A literal `null`
    shape_nothing: { fg: (gruvbox gray) }

    # shape_literal: Not currently used
    # shape_literal: { fg: (gruvbox neutral_purple) }

    # shape_operator: An operator such as +, -, ++, in, not-in, etc.
    shape_operator: { fg: (gruvbox faded_yellow) attr: 'b' }

    # shape_filepath: An argument that appears in the position of a `path` shape for a command
    shape_filepath: { fg: (gruvbox neutral_yellow) }

    # shape_directory: A more specific 'path' shape that only accepts a directory.
    shape_directory: { fg: (gruvbox neutral_yellow) }

    # shape_globpattern: An argument in the position of a glob parameter. E.g., the asterisk (or any other string) in `ls *`.
    shape_globpattern:  { fg: (gruvbox bright_yellow) attr: 'b' }

    # shape_glob_interpolation: Deprecated
    # shape_glob_interpolation: { fg: (tw amber 200) }

    # shape_garbage: When an argument is of the wrong type or cannot otherwise be parsed.
    # E.g., `ls {a: 5}` - A record argument to `ls` is 'garbage'. Also applied in real-time when
    # an expression is not (yet) properly closed.
    shape_garbage: { fg: (gruvbox fg1), bg: (gruvbox bright_red), attr: b }

    # shape_variable: The *use* of a variable. E.g., `$env` or `$a`.
    shape_variable: { fg: (gruvbox neutral_orange) }

    # shape_vardecl: The *declaration* of a variable. E.g. the "a" in `let a = 5`.
    shape_vardecl: { fg: (gruvbox fg1), attr: b }

    # shape_matching_brackets: When the cursor is positioned on an opening or closing bracket (e.g,
    # braces, curly braces, or parenthesis), and there is a matching opening/closing bracket, both will
    # temporarily have this style applied.
    shape_matching_brackets: { bg: (gruvbox bg4), attr: b }

    # shape_pipe: The pipe `|` when used to separate expressions in a pipeline
    shape_pipe: { fg: (gruvbox fg0), attr: b }

    # shape_internalcall: A known Nushell built-in or custom command in the "command position" (usually
    # the first bare word of an expression).
    shape_internalcall: { fg: (gruvbox bright_blue), attr: b }

    # shape_external: A token in the "command position" (see above) that is not a known Nushell
    # built-in or custom command. This is assumed to be an external command.
    shape_external: { fg: (gruvbox bright_blue) }

    # shape_external_resolved: Requires "highlight_resolved_externals" (above) to be enabled.
    # When a token matches the "external" requirement (above) and is also a *confirmed* external
    # command, this style will be applied.
    shape_external_resolved: { fg: (gruvbox bright_blue), attr: i }

    # shape_externalarg: Arguments to an external command (whether resolved or not)
    shape_externalarg: { fg: (gruvbox bright_orange), attr: i }

    # shape_match_pattern: The matching pattern for each arm in a match expression. Does not
    # include the guard expression (if present).
    shape_match_pattern: { fg: (gruvbox faded_yellow) attr: 'b' }

    # shape_block: The curly-braces around a block. Expressions within the block will have their
    # their own shapes' styles applied.
    shape_block: { fg: (gruvbox fg1) }

    # shape_signature: The parameter definitions and input/output types for a command signature.
    shape_signature: { fg: (gruvbox neutral_aqua), attr: i }

    # shape_keyword: Not currently used
    # shape_keyword: { fg: (tw rose 200), attr: b }

    # shape_closure: Styles the brackets and arguments of a closure.
    shape_closure: { fg: (gruvbox fg1) }

    # shape_direction: The redirection symbols such as `o>`, `error>`, `e>|`, etc.
    shape_redirection: { fg: (gruvbox bg3), attr: b }

    # shape_flag: Flags and switches to internal and custom-commands. Only the `--flag` (`-f`) portion
    # is styled. The argument to a flag will be styled using its own shape.
    shape_flag: { fg: (gruvbox bright_orange), attr: i }

    # color.config.<type>
    # *Values* of a particular *type* can be styled differently than the *shape*.
    # Note that the style is applied only when this type is displayed in *structured* data (list,
    # record, or table). It is not currently applied to basic raw values.
    #
    # Note that some types are rarely or never seen in a context in which styling would be applied.
    # For example, a cell-path *value* is unlikely to (but can) appear in a list, record, or table.
    #
    # Tip: In addition to the styles above (fg, bg, attr), types typically accept a closure which can
    # dynamically change the style based on the *value*. For instance, the themes in the nu_scripts
    # repository will style filesizes difference in an `ls` (or other table) differently depending on
    # their magnitude.

    # A boolean value
    bool: {||
      if $in {
        {
          fg: (gruvbox neutral_green)
          attr: 'b'
        }
      } else {
        {
          fg: (gruvbox neutral_red)
          attr: 'b'
        }
      }
    }

    # An integer value
    int: { fg: (gruvbox neutral_purple) }

    # A string value
    string: { fg: (gruvbox neutral_yellow) }

    # A float value
    float: { fg: (gruvbox neutral_purple) }

    # Glob value (must be declared)
    glob: { fg: (gruvbox bright_yellow) attr: 'b' }

    # Binary value
    binary: { fg: (gruvbox neutral_purple) }

    # Custom value (often from a plugin)
    custom: { fg: (gruvbox neutral_purple) }

    # Not used, since a null is not displayed
    # nothing: { fg: (gruvbox neutral_purple) }

    # Datetime value
    date: { fg: (gruvbox faded_purple) attr: 'i' }

    # filesize value
    filesize: { fg: (gruvbox faded_orange) }

    # Not currently used. Lists are displayed using their members' styles
    # list: { fg: (gruvbox fg1) }        

    # Not currently used. Records are displayed using their members' styles
    # record: { fg: (gruvbox fg1) }

    # Duration value
    duration: { fg: (gruvbox neutral_purple) }

    # A range value
    range: { fg: (gruvbox faded_purple) }

    # A cell-path value. This is a path to a cell in a table, list, or record.
    cell-path: { fg: (gruvbox fg1) } 

    # Not currently used. This is a block of code
    # closure: { fg: (tw rose 200), attr: b }

    # Not currently used. Blocks scope stuff
    # block: { fg: (tw rose 200), attr: b } 

    #
    # Additional UI elements
    #

    # hints: The (usually dimmed) style in which completion hints are displayed
    hints: { fg: (gruvbox fg4), attr: 'i' }

    # search_result: The style applied to `find` search results
    search_result: { fg: (gruvbox neutral_yellow)  }

    # header: The column names in a table header
    header: { fg: (gruvbox fg2), attr: b }

    # separator: Used for table/list/record borders
    separator: { fg: (gruvbox bg3) }

    # row_index: The `#` or `index` column of a table or list
    row_index: { fg: (gruvbox bg2), attr: b }

    # empty: This style is applied to empty/missing values in a table. However, since the ❎
    # emoji is used for this purpose, there is limited styling that can be applied.
    empty: {}

    # leading_trailing_space_bg: When a string value inside structured data has leading or trailing
    # whitespace, that whitespace will be displayed using this style.
    # Use { attr: n } to disable.
    leading_trailing_space_bg: { bg: (gruvbox bg2) }
  }
}


