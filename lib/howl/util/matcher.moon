-- Copyright 2012-2014-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

append = table.insert

separator = ' \t-_:/'
sep_p = "[#{separator}]+"
non_sep_p = "[^#{separator}]"
leading_greedy_p = "(?:^|.*#{sep_p})"
leading_p = "(?:^|.*?#{sep_p})"

boundary_part_p = (p) ->
  "(?:#{p}|#{non_sep_p}*#{sep_p}#{p})()"

case_boundary_part_p = (p) ->
  upper = p.uupper
  "(?:#{p}|#{upper}|\\p{Ll}*#{upper})()"

boundary_pattern = (search, reverse) ->
  parts = [r.escape(search[i]) for i = 1, search.ulen]
  leading = reverse and leading_greedy_p or leading_p
  p = leading .. parts[1] .. '()'
  p ..= table.concat [boundary_part_p(parts[i]) for i = 2, #parts]
  r(p)

case_boundary_pattern = (search, reverse) ->
  parts = [r.escape(search[i]) for i = 1, search.ulen]
  leading = reverse and leading_greedy_p or leading_p
  p = leading
  p ..= table.concat [case_boundary_part_p(part) for part in *parts]
  r(p)

score_for = (match, text, type, reverse, base_score) ->
  len = text.ulen

  if type == 'exact'
    if reverse
      return base_score + (len - match[2])
    else
      return len + (match[1] + base_score)

  -- boundary
  length_penalty = (len - base_score) / 3
  if reverse
    (len - match[1]) + length_penalty
  else
    start_pos = match[1]
    end_pos = match[#match]
    (end_pos - start_pos) + start_pos + length_penalty

create_matcher = (search, reverse) ->
  search = search.ulower
  boundary_p = boundary_pattern search, reverse
  case_boundary_p = case_boundary_pattern search, reverse

  (text, case_text) ->
    match = { boundary_p\match text }
    return 'boundary', match if #match > 0
    match = { case_boundary_p\match case_text }
    return 'boundary', match if #match > 0
    match = { text\ufind search, 1, true }
    return 'exact', match if #match > 0
    nil

class Matcher

  new: (@candidates, @options = {}) =>
    @_load_candidates!

  __call: (search) =>
    return [c for c in *@candidates] if not search or search.is_empty

    search = search.ulower
    prev_search = search\usub 1, -2
    matches = @cache.matches[search] or {}
    if #matches > 0 then return matches

    lines = @cache.lines[search\usub 1, -2] or @lines
    matching_lines = {}
    matcher = create_matcher search, reverse

    for i, line in ipairs lines
      text = line.text
      type, match = matcher text, line.case_text
      if match
        score = score_for match, text, type, @options.reverse, @base_score
        append matches, index: line.index, :score
        append matching_lines, line

    @cache.lines[search] = matching_lines

    unless @options.preserve_order
      table.sort matches, (a ,b) -> a.score < b.score

    matching_candidates = [@candidates[match.index] for match in *matches]
    @cache.matches[search] = matching_candidates
    matching_candidates

  explain: (search, text, options = {}) ->
    how, match = create_matcher(search, reverse)(text.ulower, text)
    return nil unless match
    if how == 'exact'
      { start_pos, end_pos } = match
      i = 2
      for pos = start_pos + 1, end_pos
        match[i] = pos
        i += 1
    else -- boundary
      match[i] -= 1 for i = 1, #match

    match.how = how
    return match

  _load_candidates: =>
    max = math.max

    @cache = lines: {}, matches: {}
    @lines = {}
    max_len = 0

    for i, candidate in ipairs @candidates do
      text = if type(candidate) == 'table' and #candidate > 0
        table.concat [tostring(c) for c in *candidate], ' '
      else
        text = tostring candidate

      append @lines, index: i, text: text.ulower, case_text: text
      max_len = max max_len, #text

    @base_score = max_len * 3

return Matcher
