
function [] = view(dm,path_spec,sort_order)
    % load the hash table
   if exist(dm.hash_table_loc,'file')==2
      load(dm.hash_table_loc)
   else
      disp('Hash table empty.')
      return
   end

   if nargin < 2
      path_spec = '';
   end
   if nargin < 3
      sort_order = 'la'; % last accessed 
   end

   if length(last_retrieved) < length(all_hashes)
      for i = length(last_retrieved)+1:length(all_hashes)
         last_retrieved{i} = '';
      end
   end

   % for sorting purposes, we combine the last retrieved with the hash
   lr_hash = last_retrieved;
   for i = 1:length(last_retrieved)
      if isempty(last_retrieved{i})
         lr_hash{i} = ['-------never--------   ' all_hashes{i}];
      else
         lr_hash{i} = [last_retrieved{i} '   ' all_hashes{i}];
      end
   end

   % sort the paths
   if strcmp(sort_order,'la')
      sorted_times = celllib.sort(lr_hash);
      for i = 1:length(all_hashes)
         % find this path in the original cell array
         this_loc = find(strcmp(sorted_times{i},lr_hash));
         if any(strfind(all_paths{this_loc},path_spec)) ||  isempty(path_spec)
            
            disp([sorted_times{i} '  '  all_paths{this_loc}])
         end
      end
   else
      sorted_paths = celllib.sort(all_paths);
      for i = 1:length(all_hashes)
         % find this path in the original cell array
         if any(strfind(sorted_paths{i},path_spec)) ||  isempty(path_spec)
            this_loc = find(strcmp(sorted_paths{i},all_paths));
            lts = last_retrieved{this_loc};
            if isempty(lts)
               lts = '-------never--------';
            end
            disp([all_hashes{this_loc} '     '  lts '    '  sorted_paths{i}])
         end
      end
   end
end % end function

