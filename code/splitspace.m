function [ full_char ] = splitspace( space_char )
    histogram_1 = sum(~space_char');
    begin_index = 1;
    while(histogram_1(begin_index) == 0)
        begin_index = begin_index + 1;
    end
    end_index = size(space_char, 1);
    while(histogram_1(end_index) == 0)
        end_index = end_index - 1;
    end
    full_char = space_char(begin_index:end_index, :);

    histogram_2 = sum(~space_char);
    left_index = 1;
    while(histogram_2(left_index) == 0)
        left_index = left_index + 1;
    end
    right_index = size(space_char, 2);
    while(histogram_2(right_index) == 0)
        right_index = right_index - 1;
    end
    full_char = full_char(:, left_index:right_index);
end

