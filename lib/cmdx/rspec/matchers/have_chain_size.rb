# frozen_string_literal: true

# Matcher to verify the size of a {CMDx::Chain}, accepting either a Chain
# directly or a {CMDx::Result} (whose +chain+ is read).
#
# @example
#   expect(result).to have_chain_size(3)
RSpec::Matchers.define :have_chain_size do |expected|
  description { "have chain size #{expected}" }

  failure_message do |actual|
    chain = extract_chain(actual)
    "expected chain size to be #{expected}, but was #{chain&.size.inspect}"
  end

  match do |actual|
    chain = extract_chain(actual)
    next false if chain.nil?

    chain.size == expected
  end

  define_method(:extract_chain) do |actual|
    case actual
    when CMDx::Chain  then actual
    when CMDx::Result then actual.chain
    end
  end
end
