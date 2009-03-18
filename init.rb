require 'redmine'

Redmine::Plugin.register :redmine_archive do
  name 'Mail Archive plugin'
  author 'Nobuhiro IMAI'
  url 'http://github.com/no6v/redmine_archive/tree/master'
  description 'This is a plugin for Mail Archive'
  version '0.0.4'
  settings :default => {"archive_key" => ""}, :partial => "settings/settings"
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
