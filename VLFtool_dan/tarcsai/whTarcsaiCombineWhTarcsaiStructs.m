function combinedStruct = whTarcsaiCombineWhTarcsaiStructs(tarcsaiResult, wh, sferic_time)
% takes the Tarcsai result struct and the whistler information struct and
% combines them into one

combinedStruct = tarcsaiResult;
combinedStruct.UT = wh.UT;
combinedStruct.station = wh.station;
combinedStruct.time = wh.time;
combinedStruct.freq = wh.freq;
combinedStruct.index = wh.index;
combinedStruct.intensity = wh.intensity;
combinedStruct.sferic_est = sferic_time;
combinedStruct.sferic_calc = sferic_time + combinedStruct.T;
