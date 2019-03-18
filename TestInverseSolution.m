    %Inverse Solution
    OPTIONS = [];
    if (isEEG==1)
      NoiseCov = diag(1e-10*ones(size(locsx,1),1));
      OPTIONS.ChannelTypes = repmat({'EEG'},[1,size(locsx,1),]);
      OPTIONS.DataTypes = {'EEG'};
    else
        NoiseCov = diag(1e-15*ones(size(locsx,1),1));
        OPTIONS.ChannelTypes = repmat({'MEG'},[1,size(locsx,1),]);
        OPTIONS.DataTypes = {'MEG'};
    end    

    OPTIONS.NoiseCovMat.NoiseCov = NoiseCov;
    OPTIONS.NoiseCovMat.nSamples  = [];
    OPTIONS.NoiseCovMat.FourthMoment = [];
    OPTIONS.InverseMethod = 'minnorm';
    OPTIONS.InverseMeasure = 'sloreta';
    OPTIONS.SourceOrient = {'fixed'};
    OPTIONS.ComputeKernel = 1;
    OPTIONS.Loose = 0.2;
    OPTIONS.UseDepth = 0;
    OPTIONS.WeightExp = 0.5;
    OPTIONS.WeightLimit = 10;
    OPTIONS.NoiseMethod = 'reg';
    OPTIONS.NoiseReg = NoiseReg;
    OPTIONS.SnrMethod = 'fixed';
    OPTIONS.SnrRms = 1e-06;
    OPTIONS.SnrFixed = SnrFixed;

    HeadModel.Gain = Gain;
    HeadModel.GridOrient = Cortex.VertNormals;
    HeadModel.GridLoc = Cortex.Vertices;
    HeadModel.HeadModelType = 'surface';

    [Results, OPTIONS] = bst_inverse_linear_2016(HeadModel, OPTIONS);
    InverseSolution=Results.ImagingKernel;
