clear all % clear all variables
clc % clear command window
addpath 'C:\Program Files\MATLAB\R2023b\toolbox\spm12'
sessions = {'RUN1', 'RUN2'};
root = 'D:\Cognitive\DTG\TG\eye track & risk-tempt\main Study\Data\New' ;

sub = {''}; % specify a list of subjects you want to process

%%
spm_dir = 'C:\Program Files\MATLAB\R2023b\toolbox\spm12' ;
addpath 'C:\Program Files\MATLAB\R2023b\toolbox\spm12' ;
spm fmri

%% Realignment: Estimate and Write

for i = 1:numel(sub) %each subj

    for sess=1:2 %each run

        disp(['Starting Realignment for ', sub{i}, sessions{sess}])

        anat_dir = fullfile(root, sub{i}, 'T1');
        func_dir = fullfile(root, sub{i}, sessions{sess});

        anat = spm_select('FPList', anat_dir, 'T1W.nii');
        func_f = spm_select('ExtFPList', func_dir, 'f.*\.nii$', Inf);
        %filenames= cellstr(spm_select('FPList',func_dir,'a.*.\.nii$'));
	    
        cd(func_dir) %functional data

        matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = cellstr(func_f);
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9; % Quality (Default: 0.9)
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4; % Separation (Default: 4)
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5; % Smoothing (FWHM) (Default: 5)
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1; % Num Passes (Default: Register to mean = 1, register to first = 0).
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2; % Interpolation (Default: 2nd Degree B-Spline)
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0]; % Wrapping (Default: No wrap)
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weigth = {}; % Weighting (Default: None)
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1]; % Resliced Images ([0 1] => Only Mean Image; Default: [2 1] => All Images + Mean Image)  Default: 2nd Degree B-Spline)
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4; % Interpolation (Default: 4th Degree B-Spline)
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0]; % Wrapping (Default: No wrap)
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1; % Masking (Default: Mask images)
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';


        save realign_batch matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed realignment for ', sub{i},sessions{sess}])
        clear matlabbatch

        disp('Press Enter to continue...');
        pause;
    end

end

disp('Realignment done')

%% Step 3: Coregistration: Estimate & Write (Anatomy to mean EPI)

for i = 1:numel(sub)
    
        disp(['Starting Coreg for ', sub{i},'-RUN1'])

        anat_dir = fullfile(root, sub{i}, 'T1');
        anat = spm_select('FPList', anat_dir, 'T1W.nii');

        run1_dir= fullfile(root, sub{i},'RUN1');
        run2_dir= fullfile(root, sub{i}, 'RUN2');

        mean_image_run1 = spm_select('ExtFPList', run1_dir, 'mean.*\.nii$', Inf);
        mean_image_run2 = spm_select('ExtFPList', run2_dir, 'mean.*\.nii$', Inf);

        cd(run1_dir)

       
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cellstr(mean_image_run1); 
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = cellstr(anat);

        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'c1';


        save coreg_batch matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed coreg for ', sub{i},'-RUN1'])
        clear matlabbatch

        cd(run2_dir)
        
        disp(['Starting Coreg for ', sub{i},'-RUN2'])
       
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cellstr(mean_image_run2); 
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = cellstr(anat);

        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'c2';



        save coreg_batch matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed coreg for ', sub{i},'-RUN2'])
        clear matlabbatch

        %disp('Press Enter to continue...');
        %pause;

   
end


disp('Coregistration done')

%% Step 4: segmentation
spm_dir = 'C:\Program Files\MATLAB\R2023b\toolbox\spm12'
for i = 1:numel(sub)
  for sess=1:2 %each run

        disp(['Starting Segmentation for ', sub{i}, sessions{sess}])

        anat_dir = fullfile(root, sub{i}, 'T1');
        if sess == 1
            % Select c1T1w.nii
            anat_c{sess} = spm_select('FPList', anat_dir, 'c1T1W.nii');
        elseif sess == 2
            % Select c2T1w.nii
            anat_c{sess} = spm_select('FPList', anat_dir, 'c2T1W.nii');
        end

        cd(anat_dir)

        matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(anat_c{sess});        %{fullfile(anat_dir, ['c' anatomical])};
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1]; % [0 0]= Save None; [0 1]= Save Bias Corrected; [1 0]= Save Bias Field; [1 1]= Save Field and Corrected
        matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spm_dir,'tpm','TPM.nii,1')};
        matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0]; % [1 0]= Native Space; [0 0]= None; [0 1]= Dartel imported; [1 1]= Native + Dartel imported
        matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spm_dir,'tpm','TPM.nii,2')};
        matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spm_dir,'tpm','TPM.nii,3')};
        matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spm_dir,'tpm','TPM.nii,4')};
        matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spm_dir,'tpm','TPM.nii,5')};
        matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spm_dir,'tpm','TPM.nii,6')};
        matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1]; % Deformation fields: [0 0]= None; [0 1]= Forward; [1 0]= Inverse; [1 1]= Inverse + Forward

        save coreg_batch matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed seg for ', sub{i},sessions{sess}])
        clear matlabbatch
        
        %disp('Press Enter to continue...');
        %pause;
  end
end


disp('segmentation done')

%% Step 5: Normalization (bias-corrected anatomical to deformation field)

for i = 1:numel(sub)


        disp(['Starting Normalization (T1) for ', sub{i},'-RUN1'])
        anat_dir = fullfile(root, sub{i}, 'T1');
        anat = spm_select('FPList', anat_dir, 'T1W.nii');

        cd(anat_dir)

        %current_subject= fullfile(results_fold,subjects{j},mprage_fold);
        def_field= cellstr(spm_select('FPList', anat_dir, '^y_c1.*\.nii')); % deformation field
        mask_image= cellstr(spm_select('FPList',  anat_dir, '^c1T1.*\.nii'));
        an_image= cellstr(spm_select('FPList',  anat_dir, '^mc1.*\.nii'));
        res_image= [mask_image; an_image];

       

        matlabbatch{1}.spm.spatial.normalise.write.subj(1).def = def_field;                 
        matlabbatch{1}.spm.spatial.normalise.write.subj(1).resample = res_image;             
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4; % Default=4
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

        save normalization_T1 matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed NormalizationT1 for ', sub{i},'-RUN1'])
        clear matlabbatch
     

        disp(['Starting Normalization (T1) for ', sub{i},'-RUN2'])
             
        def_field= cellstr(spm_select('FPList', anat_dir, '^y_c2.*\.nii')); % deformation field
        mask_image= cellstr(spm_select('FPList',  anat_dir, '^c2T1.*\.nii'));
        an_image= cellstr(spm_select('FPList',  anat_dir, '^m2.*\.nii'));
        res_image= [mask_image; an_image];

        %res_image= cellstr(spm_select('FPList', current_subject, '^m.*\.nii')); % image to align

        matlabbatch{1}.spm.spatial.normalise.write.subj(1).def = def_field;                 
        matlabbatch{1}.spm.spatial.normalise.write.subj(1).resample = res_image;           
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4; % Default=4
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';


        save normalization_T1 matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed NormalizationT1 for ', sub{i},'-RUN2'])
        clear matlabbatch
        

        %disp('Press Enter to continue...');
        %pause;
   
end


disp('Normalization (MPRAGE) done.')

%% Step 5-2: Normalization functinal data



for i = 1:numel(sub)
  
    for sess=1:2

         anat_dir = fullfile(root, sub{i}, 'T1'); 
        func_dir = fullfile(root, sub{i}, sessions{sess});

        disp(['Starting Normalization for ', sub{i}, sessions{sess}])

        if sess == 1
           def_field= cellstr(spm_select('FPList', anat_dir, 'y_c1T1W.nii'));
        elseif sess == 2 
          def_field= cellstr(spm_select('FPList', anat_dir, 'y_c2T1W.nii'));
        end

     
        cd(func_dir);
       
   
       % filenames_r{i} = cellstr(spm_select('FPList', func_dir, '^raf.*\.nii$',Inf));
       % filenames_r{1} = cellstr(spm_select('FPList', func_dir, 'raf.*\.nii$', Inf));


       % mean_filename{1}=cellstr(spm_select('FPList',func_dir,'^mean.*\.nii'));
        %all_runs_filenames= [vertcat(filenames{:}); mean_filename{1}];

        func_rf = spm_select('ExtFPList', func_dir, 'rf.*\.nii$', Inf);
        matlabbatch{1}.spm.spatial.normalise.write.subj(1).def = def_field;        
        matlabbatch{1}.spm.spatial.normalise.write.subj(1).resample = cellstr(func_rf) ; 
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb =[-78 -112 -50; 78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4; % Default=4
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';


        save normalization_func matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed Normalization for ', sub{i},sessions{sess}])
        clear matlabbatch
        
        %disp('Press Enter to continue...');
        %pause;
    end

end


disp('Normalization (func) done.')

%% Step 6: Smoothing


for i = 1:numel(sub)

    for sess=1:2


       disp(['Starting Smoothing for ', sub{i}, sessions{sess}])


        func_dir = fullfile(root, sub{i}, sessions{sess});
        cd(func_dir);
        func_wrf = spm_select('ExtFPList', func_dir, 'wrf.*\.nii$', Inf);
        %func_wr = spm_select('ExtFPList', func_dir, '^wraf*.nii', NaN);
        %filenames{i} = cellstr(spm_select('FPList', func_dir, '^wr.*\.nii$'));
        % all_runs_filenames=vertcat(filenames{1:runs_num});
        matlabbatch{1}.spm.spatial.smooth.data = cellstr(func_wrf);
        matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';


        save smoothing_batch matlabbatch
        spm_jobman('run',matlabbatch)
        disp(['Completed smoothing for ', sub{i},sessions{sess}])
        clear matlabbatch

       % disp('Press Enter to continue...');
       % pause;


    end


end


disp('Smoothing done.')
disp('===============================');
disp('Preprocessing done.')




