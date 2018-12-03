function [chinese, filename] = readChineseTemplate(dirname)
     img_path_list = dir(strcat(dirname,'*.bmp'));
     for i=1:length(img_path_list)
         fullfilename = img_path_list(i).name;
         s = regexp(fullfilename, '\.', 'split');
         filename(i) = s(1);
         file = imread(strcat(dirname, img_path_list(i).name));
         if(strcmp(filename(i), '41')==1 || strcmp(filename(i), '42')==1 || strcmp(filename(i), '43')==1)
             chinese(:,:,i) = file;
         else
             chinese(:,:,i) = ~file;
         end
     end
end
