module Padrino
  module AssetHelpers     
    module Helpers
      URI_REGEXP = %r(^[a-z]+://|^/)

      def stylesheet(*sources)
        stylesheet_link_tag(sources)
      end
      alias_method :stylesheets, :stylesheet  
      alias_method :css, :stylesheet

      def javascript(*sources)
        javascript_link_tag(sources)
      end
      alias_method :javascripts, :javascript
      alias_method :js,          :javascript
    
      def is_uri?(source)
        !!(source =~ URI_REGEXP)
      end

      def asset_path(kind, source)
        return source if is_uri?(source)  
        
        @@count ||= 0  
        if @@count < asset_host_limit
           @@count = @@count + 1 
        else
           @@count = 1
        end
        
        is_absolute      = source =~ %r{^/}
        asset_folder     = asset_folder_name(kind)
        source           = source.to_s.gsub(/\s/, '%20')
        ignore_extension = (asset_folder.to_s == kind.to_s) # don't append an extension       
        
        source << ".#{kind}" unless (ignore_extension && !(kind == :js or kind == :css) ) or source =~ /\.#{kind}/        
               
        if is_absolute
          result_path = source 
        else
          if self.class.respond_to?(:assets_host)     
            result_path = asset_host(source) 
            result_path << uri_root_path(asset_folder, source)      
          else 
            result_path = uri_root_path(asset_folder, source)      
          end    
        end

        timestamp = asset_timestamp(result_path, is_absolute)
        
        "#{result_path}#{timestamp}"
      end

    private  
      def uri_root_path(*paths)
        root_uri = settings.uri_root if settings.respond_to?(:uri_root)
        root_uri = settings.assets_uri_root if settings.respond_to?(:assets_uri_root)
        File.join(ENV['RACK_BASE_URI'].to_s, root_uri || '/', *paths)
      end 
         
      def asset_folder_name(kind)
        if kind == :css  
          asset_folder = 'stylesheets'
          asset_folder = settings.stylesheets_folder.to_s if settings.respond_to?(:stylesheets_folder)
        elsif kind == :js                               
          asset_folder = 'javascripts'                  
          asset_folder = settings.javascripts_folder.to_s if settings.respond_to?(:javascripts_folder)                
        else
          asset_folder = kind.to_s
        end 
      
        return asset_folder
      end 

      def asset_host(source)       
        unless settings.assets_host.is_a?(Proc)     
          host = settings.assets_host    
          host = settings.assets_host.gsub("%d", @@count.to_s) if settings.assets_host.index('%d')
        end  
        host = settings.assets_host(source, request) if settings.assets_host.is_a?(Proc)    
        return host
      end       
      
      def asset_host_limit()
        return 4 unless self.class.respond_to?(:assets_host_count)   
        settings.assets_host_count
      end
    end  
  end
end