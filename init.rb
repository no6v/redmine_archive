require 'redmine'

Redmine::Plugin.register :redmine_archive do
  name 'Mail Archive plugin'
  author 'Nobuhiro IMAI'
  description 'This is a plugin for Mail Archive'
  version '0.0.3'
end

module ::Redmine
  module WikiFormatting
    class << self
      def to_html_with_archive(*args, &block)
        to_html_without_archive(*args, &block).tap do |text|
          (@archiver ||= ArchiveHelper::Archiver.new).link_to_archive(text)
        end
      end

      alias_method_chain :to_html, :archive
    end
  end
end
