if command -v op &> /dev/null
  alias yarn='op run --no-masking -- yarn'
  alias pnpm='op run --no-masking -- pnpm'
  # alias bundle='op run --no-masking -- bundle'
  alias terraform='op run --no-masking -- terraform'

  alias bi='op run --no-masking -- bundle install'
  alias bu='op run --no-masking -- bundle update'
  alias gh='op run --no-masking -- gh'
  alias codex='op run --no-masking -- codex'
end
