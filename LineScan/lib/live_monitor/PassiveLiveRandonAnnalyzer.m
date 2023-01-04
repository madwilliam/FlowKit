classdef PassiveLiveRandonAnnalyzer< handle
   properties
       raw_data
       data_chunk
       n_pixel
       data_range
       radon_chunk_size
       dx
       dt
       nsample_to_show
       slope_data
       display_time
       display_data
       get_raw_data
       n_sample
       active
       counter
       pause_time
       start_y
       end_y
       pixel_start
       pixel_end
       data_queue
       initialized
   end
   
   methods
       
       function self = PassiveLiveRandonAnnalyzer(n_pixel,data_queue,radon_chunk_size,pixel_start,pixel_end, ...
             nsample_to_show)
        if ~exist('data_queue')
            self.data_queue=[];
        else
            self.data_queue = data_queue;
        end
        if ~exist('radon_chunk_size')
            self.radon_chunk_size=100;
        else
            self.radon_chunk_size = radon_chunk_size;
        end
        if ~exist('pixel_start')
            self.pixel_start=1;
        else
            self.pixel_start = pixel_start;
        end
        if ~exist('pixel_end')
            self.pixel_end=n_pixel;
        else
            self.pixel_end = pixel_end;
        end
        if ~exist('nsample_to_show')
            self.nsample_to_show=100;
        else
            self.nsample_to_show = nsample_to_show;
        end
        self.counter = 1;
        self.active = false;
        self.n_pixel = n_pixel;
        if self.pixel_start < 1 || self.pixel_start >self.pixel_end || self.pixel_start > self.n_pixel
            self.pixel_start = 1;
        end
        if self.pixel_end <1 || self.pixel_end< self.pixel_start || self.pixel_end > self.n_pixel
            self.pixel_end = self.n_pixel;
        end
        self.data_range = [self.pixel_start self.pixel_end];
        self.initialized = false;
       end

    function add_data(self,data_chunk)
        self.data_chunk = data_chunk;
        if self.n_pixel~=size(data_chunk,1)
            self.n_pixel = size(data_chunk,1);
            self.data_range = [1 size(data_chunk,1)];
            self.initialize_data_fields();
        end
        if ~self.initialized
            self.initialize_data_fields();
            self.initialized=true;
        end
        result= single_chunk_radon(data_chunk,@two_step_radon);
        self.update_data(result.slopes)
    end
    
    function initialize_data_fields(self)
        self.n_sample = size(self.data_chunk,2);
        self.slope_data = zeros(1,self.nsample_to_show);
        self.display_time = zeros(1,self.nsample_to_show);
        data_per_chunk = (self.n_sample-self.radon_chunk_size)/floor(self.radon_chunk_size*0.25)+1;
        self.display_data = zeros(self.data_range(2)-self.data_range(1)+1,floor(self.nsample_to_show/data_per_chunk*self.n_sample));
    end
    
    function update_data(self,slopes)
        n_new_points = length(slopes);
        assert(n_new_points<self.nsample_to_show)
        self.slope_data = circshift(self.slope_data,-n_new_points);
        self.display_time = circshift(self.display_time,-n_new_points);
        self.display_data = circshift(self.display_data,-self.n_sample,2);
%         self.display_time(end-n_new_points+1:end) = time+self.display_time(end-n_new_points);
        self.slope_data(end-n_new_points+1:end) = slopes;
%         self.slope_data = rectify_signal( self.slope_data,4);
        self.display_data(:,end-self.n_sample+1:end) = self.data_chunk;
        if ~isempty(self.data_queue)
            send(self.data_queue,self)
        end
    end
   end
end


