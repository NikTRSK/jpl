close all;
clear variables;
import mlreportgen.dom.*;
results_directory = '/media/jpldev/E/pix2pix_output/08Feb2018-test_supermicro/';
dnn_folder_name='08Feb2018-test_supermicro';
save_directory = '/media/jpldev/E/AlexHuyen-JanuaryMonthlyReport2018/';
gt_folder='11_Helicopter_GT/';

overlay_save_dir = strcat(save_directory, 'temp/');
mkdir(overlay_save_dir);

gt_images_dir = dir(strcat(gt_folder, '*.png'));
%% 

result_column = 1;
format = '.png';
result_array = strings(100, 100);

result_row = 1;

% Current result folder for DNN output
current_result_folder = dnn_folder_name;
result_videos = dir(results_directory);
global_min_epochs = dir(strcat(results_directory, '/', result_videos(3).name, '/',current_result_folder, '/*global*'));

total_epochs = size(global_min_epochs, 1);

total_errors = zeros(1, total_epochs-2);
total_engineering_unit_errors = zeros(1, total_epochs-2);
total_confidence = zeros(1, total_epochs-2);
sorted_epochs = strings(total_epochs-2, 1);
epoch_average_xor_error=strings(total_epochs-2, 1);
epoch_average_eu_error=strings(total_epochs-2, 1);

mkdir(strcat(save_directory,current_result_folder, '_reports'));
% Compiling all global min epochs for sorting
sorted_epoch_index = 1;
for epoch_index = 1:total_epochs
    epoch = extractBefore(global_min_epochs(epoch_index).name, '_net_G_');
    sorted_epochs(sorted_epoch_index) = epoch;
    sorted_epoch_index = sorted_epoch_index + 1;
end

% Sort only if there is more than one global minimum epoch
if size(sorted_epochs, 1) > 1
    sorted_epochs = sort_nat(sorted_epochs);
end

% Creating Report

for current_epoch_index = 1:size(sorted_epochs,1)
    doc = Document('html');
    epoch = sorted_epochs(current_epoch_index);
    for i = 1:size(gt_images_dir, 1)
       try
            index = num2str(i);
            output_case = extractBefore(gt_images_dir(i).name, '_FRAME');
            original_frame_name = gt_images_dir(i).name;
            original_frame_sb = strcat(gt_folder, original_frame_name);
            
            %gt_mask_sb = strcat(gt_folder, gt_images_dir(i).name);
            
            confidence_map_sb =  strcat(results_directory, '/', output_case, '/', dnn_folder_name, '/', epoch, '_net_G_', output_case, '/images/original_res_output/', original_frame_name);
            dnn_output_sb = strcat(results_directory, '/', output_case, '/', dnn_folder_name, '/', epoch, '_net_G_', output_case, '/images/final_output/postprocess/', original_frame_name);
            
            dnn_gt_difference_overlay_sb = strcat(overlay_save_dir, original_frame_name, '-dnn_gt_difference_overlay', format);
            dnn_mask_sb = strcat(overlay_save_dir, original_frame_name, '-dnn_mask', format);
            gt_mask_overlay_sb = strcat(overlay_save_dir, original_frame_name, '-gt_overlay', format);
            dnn_mask_overlay_sb = strcat(overlay_save_dir, original_frame_name, '-dnn_overlay', format);
            xor_mask_sb = strcat(overlay_save_dir, original_frame_name, '-dnn_gt_difference', format);
            
            original_frame_img = read(original_frame_sb);
            gt_mask_img = original_frame_img(:, 641:1280);
            original_frame_img = original_frame_img(:, 1:640);
            
            dnn_output_img = read(dnn_output_sb{1});
            %dnn_output_img = imfill(dnn_output_img, 'holes');
            %gt_mask_img = imfill(gt_mask_img, 'holes');
            dnn_mask_outline = bwmorph(dnn_output_img, 'remove');
            %dnn_mask_overlay = imfuse(original_frame_img, dnn_mask_outline);
            % convert to 3 channel gray
            dnn_mask_overlay = zeros(512,640,3);
            dnn_mask_overlay(:, :, 1) = original_frame_img;
            dnn_mask_overlay(:, :, 2) = dnn_mask_overlay(:, :, 1);
            dnn_mask_overlay(:, :, 3) = dnn_mask_overlay(:, :, 1);
            dnn_mask_overlay = dnn_mask_overlay / 255;
            % 3 dimensional logic array
            dnn_mask_outline_rgb(:, :, 3) = dnn_mask_outline;
            dnn_mask_outline_rgb(:, :, 2) = 0;
            dnn_mask_outline_rgb(:, :, 1) = 0;
            
            dnn_mask_overlay(dnn_mask_outline_rgb) = 255;
            
            gt_mask_outline = bwmorph(gt_mask_img, 'remove');
            %gt_mask_overlay = imfuse(original_frame_img, gt_mask_outline);
            gt_mask_overlay = zeros(512,640,3);
            gt_mask_overlay(:, :, 1) = original_frame_img;
            gt_mask_overlay(:, :, 2) = gt_mask_overlay(:, :, 1);
            gt_mask_overlay(:, :, 3) = gt_mask_overlay(:, :, 1);
            gt_mask_overlay = gt_mask_overlay / 255;
            % 3 dimensional logic array
            gt_mask_outline_rgb(:, :, 2) = gt_mask_outline;
            gt_mask_outline_rgb(:, :, 3) = 0;
            gt_mask_outline_rgb(:, :, 1) = 0;
            
            gt_mask_overlay(gt_mask_outline_rgb) = 255;
            
            difference_overlay = zeros(512,640, 3);
            difference_overlay(:, :, 1) = original_frame_img;
            difference_overlay(:, :, 2) = difference_overlay(:, :, 1);
            difference_overlay(:, :, 3) = difference_overlay(:, :, 1);
            difference_overlay = difference_overlay / 255;
            % 3 dimensional logic array
            combined_outline = dnn_mask_outline | gt_mask_outline;
            intersect_outline = dnn_mask_outline & gt_mask_outline;
            combined_outline_rgb(:, :, 2) = gt_mask_outline;
            combined_outline_rgb(:, :, 3) = dnn_mask_outline;
            combined_outline_rgb(:, :, 1) = 0;
            difference_overlay(combined_outline_rgb) = 255;
            %imshow(difference_overlay, 'InitialMagnification', 200); hold on;
            
            gt_mask_area = bwarea(gt_mask_img);
            dnn_mask_area = bwarea(dnn_output_img);
            xor_mask = xor(dnn_output_img, gt_mask_img);
            
            pixel_error = sum(xor_mask(:));
            gt_error = (pixel_error / gt_mask_area)*100;
            total_errors(i) = gt_error;
            confidence_map = read(confidence_map_sb{1});
            %dnn_confidence = total_confidence(confidence_map, dnn_output_img) * 100;
            
            % convert gt to binary, then to im2uint8, then
            gt_mask_indexes = im2uint8(gt_mask_img~=0)/255;
            dnn_mask_indexes = dnn_output_img/255;
            
            gt_background_indexes = im2uint8(xor(gt_mask_indexes, 1))/255;
            dnn_background_indexes = im2uint8(xor(dnn_mask_indexes, 1))/255;
            
            confidence_map_target_intensities = gt_mask_indexes .* confidence_map;
            confidence_map_bg_intensities = gt_background_indexes .* confidence_map;
            
            target_confidence = sum(sum(confidence_map_target_intensities))/sum(sum(gt_mask_indexes));
            background_confidence = sum(sum(confidence_map_bg_intensities)) / sum(sum(gt_background_indexes));
            dnn_confidence = target_confidence / (background_confidence+255) * 100;
            total_confidence(i) = dnn_confidence;
            % Calculate engineering units based on original image values
            gt_engineering_units = gt_mask_indexes .* original_frame_img;
            dnn_engineering_units = dnn_mask_indexes .* original_frame_img;
            
            gt_engineering_units_total = sum(sum(gt_engineering_units));
            dnn_engineering_units_total = sum(sum(dnn_engineering_units));
            engineering_unit_error = (abs(gt_engineering_units_total - dnn_engineering_units_total) / gt_engineering_units_total) * 100;
            total_engineering_unit_errors(i) = engineering_unit_error;
            disp(['=====Frame ', index, '=====']);
            fprintf('GT Area : %s\n',num2str(gt_mask_area));
            fprintf('Pixel Error : %s\n',num2str(pixel_error));
            fprintf('XOR Error : %s %%\n',num2str(gt_error));
            fprintf('Engineering Unit Error : %s %%\n', num2str(engineering_unit_error));
            fprintf('DNN Confidence : %s %%\n',num2str(dnn_confidence));
            imwrite(dnn_output_img, dnn_mask_sb);
            imwrite(gt_mask_overlay, gt_mask_overlay_sb);
            imwrite(dnn_mask_overlay, dnn_mask_overlay_sb);
            imwrite(xor_mask, xor_mask_sb);
            imwrite(difference_overlay, dnn_gt_difference_overlay_sb);
            
            % Table Format
            % Error %, Original, DNN Output, GT Mask, DNN Mask, Gt Outline, DNN Outline, GT
            % vs DNN XOR , GT / NN Outline
            table = Table(5);
            table.Border = 'single';
            table.ColSep = 'single';
            table.RowSep = 'single';
            
            row = TableRow;
            titleRow = TableRow;
            
            append(titleRow, TableEntry(index));
            append(titleRow, TableEntry('Original Image/Ground Truth'));
            append(titleRow, TableEntry('DNN Confidence Map'));
            %append(titleRow, TableEntry('GT Mask'));
            append(titleRow, TableEntry('DNN Mask'));
            append(titleRow, TableEntry('GT Outline'));
            append(titleRow, TableEntry('DNN Outline'));
            append(titleRow, TableEntry('GT vs NN Difference'));
            append(titleRow, TableEntry('GT vs NN Outline'));
            
            append(row, TableEntry(sprintf('%s\nGT Area: %s\nPixel Error: %s\nXOR Error: %s %%\nEngineering Unit Error: %s %%\nDNN Confidence: %s %%\n', original_frame_name, num2str(gt_mask_area), num2str(pixel_error), num2str(gt_error), num2str(engineering_unit_error), num2str(dnn_confidence))));
            
            append(row, TableEntry(Image(original_frame_sb)));
            append(row, TableEntry(Image(confidence_map_sb{1})));
            %append(row, TableEntry(Image(gt_mask_sb)));
            append(row, TableEntry(Image(dnn_mask_sb)));
            append(row, TableEntry(Image(gt_mask_overlay_sb)));
            append(row, TableEntry(Image(dnn_mask_overlay_sb)));
            append(row, TableEntry(Image(xor_mask_sb)));
            append(row, TableEntry(Image(dnn_gt_difference_overlay_sb)));
            
            append(table, titleRow);
            append(table, row);
            append(doc, table);
        catch
            disp('Frame not found');
            total_errors(i) = 100;
            total_confidence(i) = 0;
            total_engineering_unit_errors(i) = 100;
        end
    end
    disp('=====Averages=====');
    disp(sorted_epochs(current_epoch_index));
    fprintf('XOR Error Average: %s %%\n',num2str(sum(total_errors)/size(gt_images_dir, 1)));
    fprintf('Engineering Unit Error Average: %s %%\n',num2str(sum(total_engineering_unit_errors)/size(gt_images_dir, 1)));
    epoch_average_xor_error(current_epoch_index) = sprintf('XOR Error Average: %s %%',num2str(sum(total_errors)/size(gt_images_dir, 1)));
    epoch_average_eu_error(current_epoch_index) =  sprintf('Engineering Unit Error Average: %s %%',num2str(sum(total_engineering_unit_errors)/size(gt_images_dir, 1)));
    table = Table(1);
    table.Border = 'single';
    table.ColSep = 'single';
    table.RowSep = 'single';
    row = TableRow;
    append(row, TableEntry(sprintf('Average XOR Error: %s %%\nAverage Engineering Unit Error: %s %%\nAverage DNN Confidence: %s %%\n', num2str(sum(total_errors)/size(gt_images_dir, 1)), num2str(sum(total_engineering_unit_errors)/size(gt_images_dir, 1)), num2str(sum(total_confidence)/size(gt_images_dir, 1)))));
    append(table, row);
    append(doc, table);
    close(doc);
    rptview(doc.OutputPath);
    
    %w = waitforbuttonpress;
    %while w == 0
    %    w = waitforbuttonpress;
    %end
    disp('Processing next epoch')
     movefile('/tmp/mlreportgen', char(strcat(save_directory,current_result_folder,'_reports/',strcat(dnn_folder_name, '_', epoch))));
    %movefile('/tmp/mlreportgen', char(strcat('/tmp/',dnn_folder_name, '_', epoch)));
end
disp(current_result_folder);
result_array(result_row, result_column) = current_result_folder;
result_row = result_row + 1;
for epoch_index = 1:size(sorted_epochs,1)
    epoch = sorted_epochs(epoch_index);
    disp(epoch);
    disp(epoch_average_xor_error(epoch_index));
    disp(epoch_average_eu_error(epoch_index));
    
    result_array(result_row, result_column) = epoch;
    result_row = result_row + 1;
    result_array(result_row, result_column) = epoch_average_xor_error(epoch_index);
    result_row = result_row + 1;
    result_array(result_row, result_column) = epoch_average_eu_error(epoch_index);
    result_row = result_row + 2;
end
result_column = result_column + 1;