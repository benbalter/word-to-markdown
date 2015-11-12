require 'sys/proctable'

module Cliver
  class Dependency

    include Sys

    # Memoized shortcut for detect
    # Returns the path to the detected dependency
    # Raises an error if the dependency was not satisfied
    def path
      @detected_path ||= detect!
    end

    # Is the detected dependency currently open?
    def open?
      ProcTable.ps.any? { |p| p.comm == "soffice" }
    end

    # Returns the version of the resolved dependency
    def version
      return @detected_version if defined? @detected_version
      return if Gem.win_platform?
      version = installed_versions.find { |p, v| p == path }
      @detected_version = version.nil? ? nil : version[1]
    end

    def major_version
      version.split(".").first if version
    end
  end
end
