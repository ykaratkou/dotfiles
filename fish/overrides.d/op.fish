if command -v op &> /dev/null
  alias yarn='op run --no-masking -- yarn'
  alias pnpm='op run --no-masking -- pnpm'
  alias bundle='op run --no-masking -- bundle'
  alias terraform='op run --no-masking -- terraform'
end
