function [letters, filename] = readCharTemplate(dirname)
     img_path_list = dir(strcat(dirname,'*.bmp'));
     for i=1:length(img_path_list)
         fullfilename = img_path_list(i).name;
         s = regexp(fullfilename, '\.', 'split');
         filename(i) = s(1);
         file = imread(strcat(dirname, img_path_list(i).name));
         %letters(:,:,i) = imresize(~file, [110 55],'bilinear');
         letters(:,:,i) = ~file;
     end
end
