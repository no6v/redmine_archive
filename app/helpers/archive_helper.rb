require "openssl"

module ArchiveHelper
  def archive(m)
    {:controller => "archive", :action => "show", :id => __encode__(m)}
  end

  def article(id)
    __decode__(id).delete("[]").split(":")
  end

  def link_to_part(part, index)
    link_to(("%s (%s, %s)" % [
          part.disposition_param("filename", "unknown").toutf8,
          number_to_human_size(part.body.size),
          part.content_type]),
      {:part => index.next}, :class => "icon icon-attachment")
  end

  private

  def __encode__(data)
    [__cipher__(data){encrypt}].pack("m").delete("\n").tr("+/", "-_")
  end

  def __decode__(data)
    __cipher__(data.tr("-_", "+/").unpack("m").first){decrypt}
  end

  def __cipher__(data, &block)
    c = OpenSSL::Cipher.new("aes-256-cbc")
    c.instance_eval(&block)
    c.pkcs5_keyivgen(Setting.plugin_redmine_archive["archive_key"])
    result = c.update(data)
    result << c.final
  end

  class Archiver
    include ArchiveHelper
    include ActionView::Helpers::TagHelper
    include ActionController::UrlWriter

    class << self
      def default_url_options
        {:only_path => true}
      end
    end

    def link_to_archive(text)
      return if Setting.plugin_redmine_archive["archive_key"].blank?
      text.gsub!(/\[[\w@.-]+:\d+\]/) do |m|
        content_tag(:a, m, :href => url_for(archive(m)))
      end
    end
  end
end
