function outbbox_data = sparse2dense(inbbox_data)

total_col = size(inbbox_data,2);
total_row = size(inbbox_data,1);

frame_num = inbbox_data(total_row, 1);

outbbox_data = zeros(frame_num, total_col);
outbbox_data(:,1) = [1:frame_num]';

for i=1:total_row
    this_row = inbbox_data(i, 1);
    outbbox_data(this_row, :) = inbbox_data(i, :);
end

outbbox_data = outbbox_data(:,2:end);
