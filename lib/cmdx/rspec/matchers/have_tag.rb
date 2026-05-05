# frozen_string_literal: true

# Matcher to verify that a {CMDx::Result} (or task class) carries +tag+
# in its settings tags.
#
# @example
#   expect(result).to have_tag(:critical)
#   expect(MyCommand).to have_tag(:critical)
RSpec::Matchers.define :have_tag do |tag|
  description { "have tag #{tag.inspect}" }

  failure_message do |actual|
    tags = extract_tags(actual)
    "expected #{actual} to have tag #{tag.inspect}, but had #{tags.inspect}"
  end

  match do |actual|
    extract_tags(actual).include?(tag)
  end

  define_method(:extract_tags) do |actual|
    case actual
    when CMDx::Result then actual.tags
    when Class
      actual.respond_to?(:settings) ? actual.settings.tags : []
    else
      actual.respond_to?(:tags) ? actual.tags : []
    end
  end
end
