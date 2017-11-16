function annotate_images()
% Main function. Creates annotations for all images
    ground_truth_dirs = get_ground_truth_dirs('.');
    for dir = ground_truth_dirs
        generate_json(char(dir))
%         break
    end
end

function dirs = get_ground_truth_dirs(parent_dir)
% Returns a list of ground truth directories.
% Searches for all directories in parent contatining 'truths'
    all_dirs = regexp(genpath('.'), ['[^;]*'], 'match');
    ground_truth_dirs = contains(all_dirs, 'truths') == true;
    dirs = all_dirs(ground_truth_dirs);
end

function generate_json(d)
    out_file_name = strsplit(d, '\');
    d = strcat(d, '\*.png');
    files = dir(d);
    parent = files(1).folder;
    a_size = size(files);
    
%     file_name = 
    outfile = fopen(char(strcat(out_file_name(2), '_annotations.json')), 'w');
    % General info
    fprintf(outfile, '{\n"info": {\n"description": "This is stable 1.0 version of the 2014 MS COCO dataset.",\n"url": "mscoco.org",\n"version": "1.0",\n"year": 2014,\n"contributor": "Microsoft COCO group",\n"date_created": "2015-01-27 09:11:52.357475"\n},\n');
    % Licenses
    fprintf(outfile, '"licenses": [{\n"url": "www.usa.gov/copyright.shtml",\n"id": 1,\n"name": "United States Government Work"\n}\n],\n');
    
    fprintf(outfile, '"images": [');
    for i = 1: a_size(1)
        file = strcat('\', files(i).name);
        path = strcat(files(i).folder, file);
        output = process_image(char(path));
        fprintf(outfile, '%s', jsonencode(output));
        if i < a_size(1)
            fprintf(outfile, ',\n');        
        else
            fprintf(outfile, '\n');
        end
%         break;
    end
        
    fprintf(outfile, '],\n"annotations": [\n');
    
    
    

    for i = 1: a_size(1)
        file = strcat('\', files(i).name);
        path = strcat(files(i).folder, file);
        output = annotate_image(char(path));
        fprintf(outfile, '%s', jsonencode(output));
        if i < a_size(1)
            fprintf(outfile, ',\n');        
        else
            fprintf(outfile, '\n');
        end
%         break
    end
    fprintf(outfile, ']}\n');
end

function json = annotate_image(img)
    I = imread(img);
    %imshow(I)
    
    BW = im2bw(I);
    %imshow(BW)
    
    dim = size(BW);
    col = round(dim(2)/2);
    row = min(find(BW(:,col)));
    
    boundary = bwtraceboundary(BW,[row, col],'N');
%     imshow(I)
%     hold on;
%     plot(boundary(:,2),boundary(:,1),'g','LineWidth',1);
    
    output = {};
    
    x = (boundary(:,2));
    y = boundary(:,1);
    total_size = size(x) + size(y);
    
    segmentation = NaN(total_size(1), 1);
    i = 1;
    j = 1;
    seg_size = size(segmentation);
    while i <= seg_size(1)
        segmentation(i) = x(j);
        i = i + 1;
        segmentation(i) = y(j);
        i = i + 1;
        j = j + 1;
    end
    
    area = polyarea(x,y);
%     jsonencode(output);

    output.area = area;
    output.segmentation = segmentation;
%     output.bbox = ;
    output.category_id = 1;
    id = regexp(img, ['[\d]'], 'match');
    output.id = str2num(cell2mat(id));
    bbox = regionprops(BW, 'Area', 'BoundingBox');
    output.bbox = bbox.BoundingBox;
    output.iscrowd = 0;
    
    json = output;
end

function json = process_image(img)
    output = {};
    output.license = 1;
    output.url = 'unknown';
    output.filename = cell2mat(regexp(img, '[\w-]+\.png', 'match'));
    output.height = 512;
    output.width = 640;
    output.date_captured = "2017-11-14 11:18:45";
    output.id = 1;

    json = output;
end

% I = imread('1.png');
% %imshow(I)
% 
% BW = im2bw(I);
% %imshow(BW)
% 
% dim = size(BW)
% col = round(dim(2)/2)
% row = min(find(BW(:,col)))
% 
% boundary = bwtraceboundary(BW,[row, col],'N');
% imshow(I)
% hold on;
% plot(boundary(:,2),boundary(:,1),'g','LineWidth',1);
% 
% x = (boundary(:,2));
% y = boundary(:,1);
% 
% polyarea(x,y)