
# potrubi  methods for top level scripts

require_relative '../core'

mixinContent = Module.new do

  include Potrubi::Bootstrap

   # Script Methods
   # ##############
   
   def find_script_name_or_croak(scriptPath=$0)
     File.basename(scriptPath, ".*")
   end
   def find_script_directory_or_croak(scriptPath=$0)
     potrubi_bootstrap_mustbe_directory_or_croak(File.dirname(scriptPath))
   end
   
   def find_script_home_directory_or_croak(scriptPath=$0)
     potrubi_bootstrap_mustbe_directory_or_croak(File.expand_path(File.join(find_script_directory_or_croak(scriptPath), '/../')))
   end
   alias_method :find_script_home_or_croak, :find_script_home_directory_or_croak
   
   def find_script_lib_directory_or_croak(scriptPath=$0)
     potrubi_bootstrap_mustbe_directory_or_croak(File.join(find_script_home_directory_or_croak(scriptPath), 'lib'))
   end
   alias_method :find_script_lib_or_croak, :find_script_lib_directory_or_croak

   def find_script_peer_directory_or_croak(peerName, scriptPath=$0)
     potrubi_bootstrap_mustbe_directory_or_croak(File.expand_path(File.join(find_script_home_directory_or_croak(scriptPath), peerName, find_script_name_or_croak(scriptPath))))
   end
   
   def find_script_data_directory_or_croak(dirName='data', scriptPath=$0)
     find_script_peer_directory_or_croak(dirName, scriptPath)
   end
   
   def find_script_results_directory_or_croak(dirName='results', scriptPath=$0)
     find_script_peer_directory_or_croak(dirName, scriptPath)
   end
   
   def find_script_config_directory_or_croak(dirName='config', scriptPath=$0)
     find_script_peer_directory_or_croak(dirName, scriptPath)
   end
   
 end

mixinConstant = Potrubi::Core.assign_mixin_constant_or_croak(mixinContent, __FILE__)
 
mixinConstant.extend(mixinContent) # Class Methods - more likely use case

__END__

 
