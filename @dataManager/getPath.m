function [paths] = getPath(dm,hash)
   % returns the path corresponding to a hash

   % load the hash table

   if exist(dm.hash_table_loc,'file')==2
      load(dm.hash_table_loc)
   else
      error('Hash table empty.')
   end

   % look for the hash(es)
   if iscell(hash) 
   else
      hash = {hash};
   end
   paths = hash;

   % update the last retrieved 
   if exist('last_retrieved','var')
   else
      disp('No info on last retrieved, creating new variable...')
      last_retrieved = cell(length(all_hashes),1);
   end

   for i = 1:length(hash)
      this_index = find(strcmp(hash{i},all_hashes),1,'first');
      if isempty(this_index)
         disp('This hash was not found in the hash table:')
         disp(hash{i})
         error('Hash not found!')
      else
         paths{i} = all_paths{this_index};
         if dm.verbosity
            disp([hash{i} '-> ' paths{i}])
         end

         % check if this path exists
         assert(exist(paths{i},'file')>0,'File not found!')

         if ~isdir(paths{i})
            % check that the hash is correct
            try
               temp = md5(paths{i});
            catch
               Opt.Input = 'file';
               temp = dataHash(paths{i},Opt);
            end
            if ~strcmp(hash{i},temp)
               disp('File modified since last rehash. Your data has been modified, and the hashes do not match.')
               disp('File name:')
               disp(paths{i})
               disp(['Requested hash is ' hash{i}])
               disp(['Actual hash is ' temp])

               cprintf('text','\nrehash the problematic file: ')
               eval_string = ['rehash(dataManager,' char(39), paths{i} char(39) ')'];
               fprintf(['<a href="matlab:' eval_string '">rehash this file</a>']);

               error('hash check failed')
            end
         end

         last_retrieved{this_index} = datestr(now);
      end
   end

   if length(paths) == 1
      paths = paths{1}; % return a string if possible
   end

   % save
   save([fileparts(which(mfilename)) filesep 'hash_table.mat'],'last_retrieved','-append')
end