# PIX2PIX Changes for PRISM

## data folder
### data.lua
* Make a copy of `data.lua` and call it `data_512_1chan.lua`
* Modify `line 23` from `local donkey_file = 'donkey_folder.lua'` to `local donkey_file = 'donkey_folder_512_1chan.lua'`

* Make a copy of `data.lua` and call it `data_512_1chan_test.lua`
* Modify `line 23` from `local donkey_file = 'donkey_folder.lua'` to `local donkey_file = 'donkey_folder_512_1chan_test.lua'`

### dataset256_3chan.lua
* Make a copy of `dataset256_3chan.lua` and call it `dataset.lua`
* After the following code on `line 156`

```
   -- Options for the GNU find command
   local extensionList = {'jpg', 'png','JPG','PNG','JPEG', 'ppm', 'PPM', 'bmp', 'BMP'}
   local findOptions = ' -iname "*.' .. extensionList[1] .. '"'
```
add `local sortOptions = ' | sort -V '`

The code should look like this:
```
   -- Options for the GNU find command
   local extensionList = {'jpg', 'png','JPG','PNG','JPEG', 'ppm', 'PPM', 'bmp', 'BMP'}
   local findOptions = ' -iname "*.' .. extensionList[1] .. '"'
   local sortOptions = ' | sort -V '
```

* on `line 183` change the code:
```
local command = find .. ' "' .. path .. '" ' .. findOptions
  .. ' >>"' .. classFindFiles[i] .. '" \n'
```

to

```
local command = find .. ' "' .. path .. '" ' .. findOptions
  .. sortOptions .. ' >>"' .. classFindFiles[i] .. '" \n'
```

* on `line 219` after `local count = 0` add the line `local sort_lines = {}`

### donkey_folder.lua
* Make a copy of `donkey_folder.lua` and call it `donkey_folder_512_1chan.lua`
* Modify `line 42` from `local perm = torch.LongTensor{3, 2, 1}` to `local perm = torch.LongTensor{1}`
  * This changes the loading of the images from 3 channel RGB to 1 channel

### donkey_folder_test.lua
* Make a copy of `donkey_folder_test.lua` and call it `donkey_folder_512_1chan_test.lua`
* Modify `line 42` from `local perm = torch.LongTensor{3, 2, 1}` to `local perm = torch.LongTensor{1}`
  * This changes the loading of the images from 3 channel RGB to 1 channel

## util folder
### util.lua
* Make a copy of `util.lua` and call it `util_512_1chan.lua`
* Comment out `lines 41, 42` (-- for comments in lua)
  ```
  --local perm = torch.LongTensor{3, 2, 1}
  --img = img:index(1, perm)
  ```
* Comment out `lines 57, 58` (-- for comments in lua)
  ```
  --local perm = torch.LongTensor{3, 2, 1}
  --img = img:index(1, perm)
  ```

## root directory
### models.lua
* Make a copy of `models.lua` and call it `models512_1chan.lua`
* modify the `defineG_unet` function from
  ```
  function defineG_unet(input_nc, output_nc, ngf)
    local netG = nil
    -- input is (nc) x 256 x 256
    local e1 = - nn.SpatialConvolution(input_nc, ngf, 4, 4, 2, 2, 1, 1)
    -- input is (ngf) x 128 x 128
    local e2 = e1 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf, ngf * 2, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 2)
    -- input is (ngf * 2) x 64 x 64
    local e3 = e2 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 2, ngf * 4, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 4)
    -- input is (ngf * 4) x 32 x 32
    local e4 = e3 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 4, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 16 x 16
    local e5 = e4 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 8 x 8
    local e6 = e5 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 4 x 4
    local e7 = e6 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 2 x 2
    local e8 = e7 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) -- nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 1 x 1
    
    local d1_ = e8 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8) - nn.Dropout(0.5)
    -- input is (ngf * 8) x 2 x 2
    local d1 = {d1_,e7} - nn.JoinTable(2)
    local d2_ = d1 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8) - nn.Dropout(0.5)
    -- input is (ngf * 8) x 4 x 4
    local d2 = {d2_,e6} - nn.JoinTable(2)
    local d3_ = d2 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8) - nn.Dropout(0.5)
    -- input is (ngf * 8) x 8 x 8
    local d3 = {d3_,e5} - nn.JoinTable(2)
    local d4_ = d3 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 16 x 16
    local d4 = {d4_,e4} - nn.JoinTable(2)
    local d5_ = d4 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 4, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 4)
    -- input is (ngf * 4) x 32 x 32
    local d5 = {d5_,e3} - nn.JoinTable(2)
    local d6_ = d5 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 4 * 2, ngf * 2, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 2)
    -- input is (ngf * 2) x 64 x 64
    local d6 = {d6_,e2} - nn.JoinTable(2)
    local d7_ = d6 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 2 * 2, ngf, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf)
    -- input is (ngf) x128 x 128
    local d7 = {d7_,e1} - nn.JoinTable(2)
    local d8 = d7 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 2, output_nc, 4, 4, 2, 2, 1, 1)
    -- input is (nc) x 256 x 256
    
    local o1 = d8 - nn.Tanh()
    
    netG = nn.gModule({e1},{o1})
    
    --graph.dot(netG.fg,'netG')
    
    return netG
  end
  ```

  to

  ```
  function defineG_unet(input_nc, output_nc, ngf)
    local netG = nil
    -- input is (nc) x 256 x 256
    local e1 = - nn.SpatialConvolution(input_nc, ngf, 4, 4, 2, 2, 1, 1)
    -- input is (ngf) x 128 x 128
    local e2 = e1 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf, ngf * 2, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 2)
    -- input is (ngf * 2) x 64 x 64
    local e3 = e2 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 2, ngf * 4, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 4)
    -- input is (ngf * 4) x 32 x 32
    local e4 = e3 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 4, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 16 x 16
    local e5 = e4 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 8 x 8
    local e6 = e5 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 4 x 4
    local e7 = e6 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    local e8 = e7 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 2 x 2
    local e9 = e8 - nn.LeakyReLU(0.2, true) - nn.SpatialConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) -- nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 1 x 1
    
    local d1_ = e9 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8) - nn.Dropout(0.5)
    -- input is (ngf * 8) x 2 x 2
    local d1 = {d1_,e8} - nn.JoinTable(2)
    local d2_ = d1 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8) - nn.Dropout(0.5)
    -- input is (ngf * 8) x 4 x 4
    local d2 = {d2_,e7} - nn.JoinTable(2)
    local d3_ = d2 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8) - nn.Dropout(0.5)
    -- input is (ngf * 8) x 8 x 8
    local d3 = {d3_,e6} - nn.JoinTable(2)

    local d4_ = d3 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 16 x 16
    local d4 = {d4_,e5} - nn.JoinTable(2)

    local d5_ = d4 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 8, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 8)
    -- input is (ngf * 8) x 16 x 16
    local d5 = {d5_,e4} - nn.JoinTable(2)
    
    local d6_ = d5 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 8 * 2, ngf * 4, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 4)
    -- input is (ngf * 4) x 32 x 32
    local d6 = {d6_,e3} - nn.JoinTable(2)
    
    local d7_ = d6 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 4 * 2, ngf * 2, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf * 2)
    -- input is (ngf * 2) x 64 x 64
    local d7 = {d7_,e2} - nn.JoinTable(2)
    
    local d8_ = d7 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 2 * 2, ngf, 4, 4, 2, 2, 1, 1) - nn.SpatialBatchNormalization(ngf)
    -- input is (ngf) x128 x 128
    local d8 = {d8_,e1} - nn.JoinTable(2)
    
    local d9 = d8 - nn.ReLU(true) - nn.SpatialFullConvolution(ngf * 2, output_nc, 4, 4, 2, 2, 1, 1)
    -- input is (nc) x 256 x 256
    
    local o1 = d9 - nn.Tanh()
    
    netG = nn.gModule({e1},{o1})
    
    --graph.dot(netG.fg,'netG')
    
    return netG
  end
  ```

  ### test.lua
  * Make a copy of `test.lua` and call it `test512_1chan.lua`
  * Change `line 9` from `util = paths.dofile('util/util.lua')` to `	util = paths.dofile('util/util_512_1chan.lua')`
  * Change `lines 15, 16` from `loadSize = 256, fineSize = 256,` to `loadSize = 512, fineSize = 512,`
  * Change `lines 27, 28` from `input_nc = 3, output_nc = 3,` to `input_nc = 1, output_nc = 1,`
  * Change `line 54` from `local data_loader = paths.dofile('data/data.lua')` to `local data_loader = paths.dofile('data/data_512_1chan_test.lua')`
  * Comment out `line 114`: `local target = torch.FloatTensor(opt.batchSize,3,opt.fineSize,opt.fineSize)`
  * Comment out `line 138`: `dim[3] = dim[3]/2`
  * Comment out `line 157`: `target = data_curr[{ {}, idx_B, {}, {} }]`
  * Comment out `line 167`: `local target_AB = target:float()`
  * Comment out `line 168`: `target = util.deprocessLAB_batch(input_L, target_AB)`
  * Comment out `line 174`: `target = util.deprocess_batch(target):float()`
  * Change `lines 181, 182` from
    ```
    paths.mkdir(paths.concat(image_dir,'full_target_output'))
    paths.mkdir(paths.concat(image_dir,'target'))
    ```
  to
    ```
    paths.mkdir(paths.concat(image_dir,'original_res_output'))
    --paths.mkdir(paths.concat(image_dir,'target'))
    ```
  * Change `line 185` from
  ```
  for i=1, opt.batchSize do
    img = binarize(image.rgb2y(image.scale(output[i], dimensions[num][3], dimensions[num][2])),0.1)
  ```
to
  ```
  for i=1, opt.batchSize do
    --img = binarize(image.rgb2y(image.scale(output[i], dimensions[num][3], dimensions[num][2])),0.1)
    --img = image.rgb2y(image.scale(output[i], dimensions[num][3], dimensions[num][2]))
    img = image.scale(output[i], dimensions[num][3], dimensions[num][2])
  ```
  * Change `line 189` from
  ```
  image.save(paths.concat(image_dir,'full_target_output',filepaths_curr[i]), img)
  image.save(paths.concat(image_dir,'target',filepaths_curr[i]), image.scale(target[i],target[i]:size(2),target[i]:size(3)/opt.aspect_ratio))
  ```
to
  ```
  image.save(paths.concat(image_dir,'original_res_output',filepaths_curr[i]), img)
  --image.save(paths.concat(image_dir,'target',filepaths_curr[i]), image.scale(target[i],target[i]:size(2),target[i]:size(3)/opt.aspect_ratio))
  ```
  * Comment out `line 200`: `disp.image(util.scaleBatch(target,100,100),{win=opt.display_id+2, title='target'})`
  * OPTIONAL: Change `line 223` from `io.write('<tr><td>Image #</td><td>Input</td><td>Output</td><td>Ground Truth</td></tr>')` to `	io.write('<tr><td>Image #</td><td>Input</td><td>Output</td></tr>')`

  ### train.lua
  * Make a copy of `train.lua` and call it `train_512_1chan.lua`
  * Change `line 9` from `util = paths.dofile('util/util.lua')` to `util = paths.dofile('util/util_512_1chan.lua')`
  * Change `line 11` from `require 'models'` to `require 'models512_1chan'`
  * Change `lines 17, 18` from `loadSize = 286, fineSize = 256,` to `loadSize = 512, fineSize = 512,`
  * Change `lines 21, 22` from `input_nc = 3, output_nc = 3,` to `input_nc = 1, output_nc = 1,`
  * Change `line 30` from `display_plot = 'train_errL1',` to `display_plot = 'errL1',`
  * Remove the function `deepcopy(orig)`
  * Remove `lines 80, 81`: `test_opt = deepcopy(opt)`, `test_opt.phase = 'test'`
  * Change `line 104` from `local data_loader = paths.dofile('data/data.lua')` to `local data_loader = paths.dofile('data/data_512_1chan.lua')`
  * Remove `lines 109 - 116`:
  ```
  print(tmp_d:size())
  local test_data_loader = paths.dofile('data/data.lua')
  print('Test #threads...' .. test_opt.nThreads)
  local test_data = test_data_loader.new(test_opt.nThreads, test_opt)
  print("Test Dataset Size: ", test_data:size())
  test_tmp_d, test_tmp_paths = test_data:getBatch()
  print(test_tmp_d:size())
  ```
  * Change `lines 202, 203` from
  ```
  local train_errD, train_errG, train_errL1, train_errL1_plot = 0, 0, 0, 0
  local test_errD, test_errG, test_errL1 = 0, 0, 0
  ```
to
  `local errD, errG, errL1 = 0, 0, 0`
  * Change `line 273` from `local train_errD_real = criterion:forward(output, label)` to `local errD_real = criterion:forward(output, label)`
  * Change `line 280` from `local train_errD_fake = criterion:forward(output, label)` to `local errD_fake = criterion:forward(output, label)`
  * Change `line 284` from `train_errD = (train_errD_real + train_errD_fake)/2` to `errD = (errD_real + errD_fake)/2`
  * Change `line 286` from `return train_errD, gradParametersD` to `return errD, gradParametersD`
  * Change `line 308` from `train_errG = criterion:forward(output, label)` to `errG = criterion:forward(output, label)`
  * Change `line 312` from `train_errG = 0` to `errG = 0`
  * Change `lines 321 - 418` from
  ```
       train_errL1 = criterionAE:forward(fake_B, real_B)
       df_do_AE = criterionAE:backward(fake_B, real_B)
    else
        train_errL1 = 0
    end

    netG:backward(real_A, df_dg + df_do_AE:mul(opt.lambda))

    return train_errG, gradParametersG
end

function createRealFake_test()
    -- load real
    data_tm:reset(); data_tm:resume()
    local real_data, data_path = test_data:getBatch()
    data_tm:stop()
    real_A:copy(real_data[{ {}, idx_A, {}, {} }])
    real_B:copy(real_data[{ {}, idx_B, {}, {} }])

    if opt.condition_GAN==1 then
        real_AB = torch.cat(real_A,real_B,2)
    else
        real_AB = real_B -- unconditional GAN, only penalizes structure in B
    end

    -- create fake
    fake_B = netG:forward(real_A)

    if opt.condition_GAN==1 then
        fake_AB = torch.cat(real_A,fake_B,2)
    else
        fake_AB = fake_B -- unconditional GAN, only penalizes structure in B
    end
end

-- create closure to evaluate f(X) and df/dX of discriminator
local fDx_test = function(x)
    netD:apply(function(m) if torch.type(m):find('Convolution') then m.bias:zero() end end)
    netG:apply(function(m) if torch.type(m):find('Convolution') then m.bias:zero() end end)

    gradParametersD:zero()

    -- Real
    local output = netD:forward(real_AB)
    local label = torch.FloatTensor(output:size()):fill(real_label)
    if opt.gpu>0 then
      label = label:cuda()
    end

    local test_errD_real = criterion:forward(output, label)
    local df_do = criterion:backward(output, label)
    netD:backward(real_AB, df_do)

    -- Fake
    local output = netD:forward(fake_AB)
    label:fill(fake_label)
    local test_errD_fake = criterion:forward(output, label)
    local df_do = criterion:backward(output, label)
    netD:backward(fake_AB, df_do)

    test_errD = (test_errD_real + test_errD_fake)/2

    return test_errD, gradParametersD
end

-- create closure to evaluate f(X) and df/dX of generator
local fGx_test = function(x)
    netD:apply(function(m) if torch.type(m):find('Convolution') then m.bias:zero() end end)
    netG:apply(function(m) if torch.type(m):find('Convolution') then m.bias:zero() end end)

    gradParametersG:zero()

    -- GAN loss
    local df_dg = torch.zeros(fake_B:size())
    if opt.gpu>0 then
      df_dg = df_dg:cuda();
    end

    if opt.use_GAN==1 then
       local output = netD.output -- netD:forward{input_A,input_B} was already executed in fDx, so save computation
       local label = torch.FloatTensor(output:size()):fill(real_label) -- fake labels are real for generator cost
       if opt.gpu>0 then
        label = label:cuda();
        end
       test_errG = criterion:forward(output, label)
       local df_do = criterion:backward(output, label)
       df_dg = netD:updateGradInput(fake_AB, df_do):narrow(2,fake_AB:size(2)-output_nc+1, output_nc)
    else
        test_errG = 0
    end

    -- unary loss
    local df_do_AE = torch.zeros(fake_B:size())
    if opt.gpu>0 then
      df_do_AE = df_do_AE:cuda();
    end
    if opt.use_L1==1 then
       test_errL1 = criterionAE:forward(fake_B, real_B)
  ```
to
  `errL1 = criterionAE:forward(fake_B, real_B)`
  * Change `line 421` from `test_errL1 = 0` to `errL1 = 0`
  * Change `line 426` from `return test_errG, gradParametersG` to `return errG, gradParametersG`
  * Change `line 445` from `if not util.containsValue({"train_errG", "train_errD", "train_errL1", "test_errL1"}, v) then` to `if not util.containsValue({"errG", "errD", "errL1"}, v) then`
  * Change `line 453` from `labels = {"epoch", "train_errL1", "test_errL1"},` to `labels = {"epoch", unpack(opt.display_plot)},`
  * Remove `lines 460 - 462`
  ```
  local plot_data_test = {}
  local plot_vals = {}
  local test_plot_vals = {}
  ```
  * Remove `line 466`: `local test_counter = 0`
  * Change `lines 489 - 495` from:
  ```
                  disp.image(util.deprocessL_batch(real_A_s), {win=opt.display_id, title=opt.name .. ' train_input'})
                disp.image(util.deprocessLAB_batch(real_A_s, fake_B_s), {win=opt.display_id+1, title=opt.name .. ' train_output'})
                disp.image(util.deprocessLAB_batch(real_A_s, real_B_s), {win=opt.display_id+2, title=opt.name .. ' train_target'})
            else
                disp.image(util.deprocess_batch(util.scaleBatch(real_A:float(),100,100)), {win=opt.display_id, title=opt.name .. ' train_input'})
                disp.image(util.deprocess_batch(util.scaleBatch(fake_B:float(),100,100)), {win=opt.display_id+1, title=opt.name .. ' train_output'})
                disp.image(util.deprocess_batch(util.scaleBatch(real_B:float(),100,100)), {win=opt.display_id+2, title=opt.name .. ' train_target'})
  ```
to
  ```
                disp.image(util.deprocessL_batch(real_A_s), {win=opt.display_id, title=opt.name .. ' input'})
                disp.image(util.deprocessLAB_batch(real_A_s, fake_B_s), {win=opt.display_id+1, title=opt.name .. ' output'})
                disp.image(util.deprocessLAB_batch(real_A_s, real_B_s), {win=opt.display_id+2, title=opt.name .. ' target'})
            else
                disp.image(util.deprocess_batch(util.scaleBatch(real_A:float(),100,100)), {win=opt.display_id, title=opt.name .. ' input'})
                disp.image(util.deprocess_batch(util.scaleBatch(fake_B:float(),100,100)), {win=opt.display_id+1, title=opt.name .. ' output'})
                disp.image(util.deprocess_batch(util.scaleBatch(real_B:float(),100,100)), {win=opt.display_id+2, title=opt.name .. ' target'})
  ```
  * Change `line 532` from `local loss = {train_errG=train_errG and train_errG or -1, train_errD=train_errD and train_errD or -1, train_errL1=train_errL1 and train_errL1 or -1}` to `local loss = {errG=errG and errG or -1, errD=errD and errD or -1, errL1=errL1 and errL1 or -1}`
  * Change `line 536` from `.. '  Train_Err_G: %.4f  Train_Err_D: %.4f  Train_ErrL1: %.4f'):format(` to `.. '  Err_G: %.4f  Err_D: %.4f  ErrL1: %.4f'):format(`
  * Change `lines 539-541` from 
  ```
  train_errG, train_errD, train_errL1))
  train_errL1_plot = deepcopy(train_errL1)
  plot_vals = { epoch + curItInBatch / totalItInBatch }
  ```
to
  ```
  errG, errD, errL1))

  local plot_vals = { epoch + curItInBatch / totalItInBatch }
  ```
  * Remove `lines 548-576`
  ```
              -- test curve
            ---[[
            createRealFake_test()

            -- (1) Update D network: maximize log(D(x,y)) + log(1 - D(x,G(x)))
            --if opt.use_GAN==1 then optim.adam(fDx, parametersD, optimStateD) end
            fDx_test(test_data)
            -- (2) Update G network: maximize log(D(x,G(x))) + L1(y,G(x))
            --optim.adam(fGx, parametersG, optimStateG)
            fGx_test(test_data)

             if opt.preprocess == 'colorization' then
                local real_A_s = util.scaleBatch(real_A:float(),100,100)
                local fake_B_s = util.scaleBatch(fake_B:float(),100,100)
                local real_B_s = util.scaleBatch(real_B:float(),100,100)
                disp.image(util.deprocessL_batch(real_A_s), {win=opt.display_id+3, title=opt.name .. ' test_input'})
                disp.image(util.deprocessLAB_batch(real_A_s, fake_B_s), {win=opt.display_id+4, title=opt.name .. ' test_output'})
                disp.image(util.deprocessLAB_batch(real_A_s, real_B_s), {win=opt.display_id+5, title=opt.name .. ' test_target'})
            else
                disp.image(util.deprocess_batch(util.scaleBatch(real_A:float(),100,100)), {win=opt.display_id+3, title=opt.name .. ' test_input'})
                disp.image(util.deprocess_batch(util.scaleBatch(fake_B:float(),100,100)), {win=opt.display_id+4, title=opt.name .. ' test_output'})
                disp.image(util.deprocess_batch(util.scaleBatch(real_B:float(),100,100)), {win=opt.display_id+5, title=opt.name .. ' test_target'})
            end

            local test_loss = {test_errG=test_errG and test_errG or -1, test_errD=test_errD and test_errD or -1, test_errL1=test_errL1 and test_errL1 or -1}
            print(('Epoch: [%d]  Test_Err_G: %.4f  Test_Err_D: %.4f  Test_ErrL1: %.4f'):format(
                     epoch, test_errG, test_errD, test_errL1))
                     --]]
  ```
  * Change `lines 579,580` from
  ```
    table.insert(plot_data, {epoch, train_errL1, test_errL1})
  --table.insert(plot_data, train_errL1)
  ```
to `table.insert(plot_data, plot_vals)`
  * Remove `lines 597-603`
  ```
  -- update display plot
  --if opt.display then
  --  table.insert(plot_data, plot_vals)
  --  plot_config.win = plot_win
  --  plot_win = disp.plot(plot_data, plot_config)
  --end
  ```