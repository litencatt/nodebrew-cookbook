class Chef
  module Mixin
    module Nodebrew
      include Chef::Mixin::ShellOut

      def nodebrew_cmd(cmd, options = {})
        unless nodebrew_installed?
          Chef::Log.error <<-MSG.gsub(/\s{2,}/, '').strip
            nodebrew is not yet installed. Unable to run nodebrew_command: `#{cmd}`.
            Are you trying to use `nodebrew_cmd` at the top level of your recipe?
            This is known to cause this error
          MSG
          raise "nodebrew not installed. Can't run nodebrew_cmd"
        end

        merged_options = Chef::Mixin::DeepMerge.deep_merge!(options, {
          :user => node[:nodebrew][:user],
          :cwd => nodebrew_root,
          :env => { 'NODEBREW_ROOT' => nodebrew_root },
          :timeout => 3600
        })

        shell_out(add_nodebrew_path(cmd), merged_options)
      end

      def add_nodebrew_path(cmd)
        command = <<-CMD.strip.gsub(/^ {4}/, '')
          export NODEBREW_ROOT="#{nodebrew_root}"
          export PATH="${NODEBREW_ROOT}/current/bin:$PATH"
          #{cmd}
        CMD
        command
      end

      def nodebrew_root
        node[:nodebrew][:root]
      end

      def nodebrew_binary_path
        "#{nodebrew_root}/current/bin/nodebrew"
      end

      def nodebrew_installed?
        out = shell_out("ls #{nodebrew_binary_path}")
        out.exitstatus.zero?
      end

      def node_installed?(version)
        out = nodebrew_cmd("nodebrew ls | grep #{version}")
        out.exitstatus.zero?
      end
    end
  end
end
