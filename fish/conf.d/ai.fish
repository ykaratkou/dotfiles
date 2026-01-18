function _askclaudequick
  if test (count $argv) -eq 0
    echo "Usage: ?? <prompt>"
    return 1
  end

  set base_instruction "You are a terminal CLI helper tool. Be concise and practical."
  set user_prompt (string join " " $argv)
  set prompt "$base_instruction\n\n$user_prompt"

  set session_id (uuidgen | string lower)

  claude -p --session-id $session_id $prompt

  while true
    echo ""
    read -P (set_color blue)">> "(set_color normal) followup

    if test -z "$followup"
      break
    end

    claude --model haiku -p --resume $session_id $followup
  end
end

alias ??='askclaudequick'
