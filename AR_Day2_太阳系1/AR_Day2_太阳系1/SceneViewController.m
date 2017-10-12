//
//  SceneViewController.m
//  AR_Day2_太阳系1
//
//  Created by 王永顺 on 2017/9/13.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

#import "SceneViewController.h"
//1.导入头文件
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface SceneViewController ()<ARSCNViewDelegate>

@property (nonatomic,strong) ARSCNView *arSCNView;
@property (nonatomic,strong) ARSession *arSession;
@property (nonatomic,strong) ARConfiguration *arSessionConfiguration;

//地球🌎 太阳🌞 月亮🌛
@property (nonatomic,strong) SCNNode *sunNode;
@property (nonatomic,strong) SCNNode *moonNode;
@property (nonatomic,strong) SCNNode *earthNode;

//地月节点: set earth and moon
@property(nonatomic, strong)SCNNode * earthGroupNode;
@property(nonatomic, strong)SCNNode * sunHaloNode;

@end

@implementation SceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化 AR环境
    [self.view addSubview:self.arSCNView];
    self.arSCNView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
    //创建追踪
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    //自适应灯光（室内到室外，画面会比较柔和点）
    _arSessionConfiguration = configuration;
    _arSessionConfiguration.lightEstimationEnabled = true;
    [self.arSession runWithConfiguration:configuration];
}

-(void)initNode {
    _sunNode = [SCNNode new];
    _earthNode = [SCNNode new];
    _moonNode = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    
    //确定节点几何
    _sunNode.geometry = [SCNSphere sphereWithRadius:3];
    _earthNode.geometry = [SCNSphere sphereWithRadius:1.0];
    _moonNode.geometry = [SCNSphere sphereWithRadius:0.5];
    
    //渲染上图
    //multiply 镶嵌 把整张图片拉伸，之后会变淡
    //diffuse 扩散 平均扩散到整个物件的表面，并且光华透亮
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;//强度
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    //地球上图
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
    //    地球夜光图
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
    
    //月球图
    _moonNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
    
    //    wrapS 从左到右
    //    wrapT 从上到下 （回头提醒我把这边住掉很吓人）
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    
    //太阳照到地球上的光泽，还有反光度，地球的反光度
    _earthNode.geometry.firstMaterial.shininess = 0.1;//光泽
    _earthNode.geometry.firstMaterial.specular.intensity = 0.5;//反射多少光出去
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor grayColor];//
    
    //设置太阳的位置
    [_sunNode setPosition:SCNVector3Make(0, 5, -20)];
    
    //设置地球、月球的位置
    _earthNode.position = SCNVector3Make(3, 0, 0);
    _moonNode.position = SCNVector3Make(3, 0, 0);
    
    //set earth in earthGround
    [_earthGroupNode addChildNode:_earthNode];
    
    //    set earthGround posittion
    _earthGroupNode.position = SCNVector3Make(10, 0, 0);
    
    [self.arSCNView.scene.rootNode addChildNode:_sunNode];
    
    [self addAnimationToSun];
    
    [self roationNode];
    
    [self addLight];
}

#pragma mark-公转
-(void)roationNode {
    
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];//地球自转
    //设置月球围绕地球转动
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    
    //月球自转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 1.5;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    animation.repeatCount = FLT_MAX;
    [_moonNode addAnimation:animation forKey:@"moon rotation"];
    
    //月球围绕地球转动
    CABasicAnimation *moonRatationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRatationAnimation.duration = 5.0;
    moonRatationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    moonRatationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:moonRatationAnimation forKey:@"moon rotation around earth"];
    
    //    [moonRotationNode addChildNode:_moonNode];
    [_earthGroupNode addChildNode:moonRotationNode];
    
    //    地球繞著太陽轉
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    [earthRotationNode addChildNode:_earthGroupNode];
    
    //    earth rotate sun
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 10.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
}

#pragma mark-太阳自转
-(void)addAnimationToSun {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    
    animation.duration = 10.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
}

-(void)addLight {
    
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor redColor];
//    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    
    lightNode.light.attenuationEndDistance = 20.0;
    lightNode.light.attenuationStartDistance = 1.0;
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        
        lightNode.light.color = [UIColor whiteColor]; // switch on
        _sunHaloNode.opacity = 0.5; // make the halo stronger
    }
    [SCNTransaction commit];
    
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:25 height:25];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
    _sunHaloNode.opacity = 0.9;
    [_sunNode addChildNode:_sunHaloNode];
}

#pragma lazy load

- (ARSession *)arSession{
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    return _arSession;
}

- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    
    //初始化节点
    [self initNode];
    
    return _arSCNView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
