
# potrubi filesystem methods

require_relative '../core'

require 'fileutils'

mixinContent = Module.new do

   # FileSys Methods
   # ###############
   
   def filesys_find_path_or_croak(*paths, &block)
     mustbe_file_or_directory_or_croak(normalise_pathandname_paths_or_croak(*paths, &block))
   end
   alias_method :find_path_or_croak, :filesys_find_path_or_croak

   def filesys_find_file_or_croak(*paths, &block)
     mustbe_file_or_croak(normalise_pathandname_paths_or_croak(*paths, &block))
   end
   alias_method :find_file_or_croak, :filesys_find_file_or_croak

   def filesys_find_directory_or_croak(*paths, &block)
     mustbe_directory_or_croak(normalise_pathandname_paths_or_croak(*paths, &block))
   end
   alias_method :find_directory_or_croak, :filesys_find_directory_or_croak
   alias_method :find_dir_or_croak, :filesys_find_directory_or_croak

   def create_filesys_path_directory_or_croak(*pathElements)
     eye = :cpn_path_dir_or_croak
     pathName = normalise_pathandname_paths_or_croak(*pathElements)
     dirName = File.dirname(pathName)
     filesys_create_directory_or_croak(dirName)
   end
   alias_method :create_path_directory_or_croak, :create_filesys_path_directory_or_croak
   alias_method :create_path_dir_or_croak, :create_filesys_path_directory_or_croak
   
   def filesys_create_directory_or_croak(*pathElements)
     eye = :cpn_dir_or_croak
     dirName = normalise_pathandname_paths_or_croak(*pathElements)
     case
     when File.directory?(dirName) then dirName
     when (! File.exists?(dirName)) then
           FileUtils.mkdir_p(dirName) 
            mustbe_directory_or_croak(dirName, eye, "failed to create directory")
         else
            duplicate_exception(dirName, eye, "dirName already exists but not a directory")
         end
    end
   alias_method :create_directory_or_croak, :filesys_create_directory_or_croak
   alias_method :create_dir_or_croak, :filesys_create_directory_or_croak
   
   def filesys_find_path_base_or_croak(*paths, &block)  # without the .rb if any
     fullPath = normalise_pathandname_paths_or_croak(*paths, &block)
     basePath = File.join(File.dirname(fullPath), File.basename(fullPath, ".rb"))
     $DEBUG && logger_ca(:f_pan_p_base, logger_fmt_who(:basePath => basePath, :fullPath => fullPath, :paths => paths))
     mustbe_directory_or_croak(basePath)
   end

   def filesys_find_mixin_home_or_croak(*paths, &block)
     mixinPath = File.join(filesys_find_path_base_or_croak(*paths), 'mixin')
     $DEBUG && logger_ca(:f_mix_home, logger_fmt_who(:mixinPath => mixinPath, :paths => paths))
     mustbe_directory_or_croak(mixinPath)
   end
   alias_method :find_mixin_home_or_croak, :filesys_find_mixin_home_or_croak

 end


mixinConstant = Potrubi::Core.assign_mixin_constant_or_croak(mixinContent, :Potrubi, :Mixin, :Filesys)

__END__

