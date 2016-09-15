//
//  GameViewController.m
//  phyandcoltest
//
//  Created by 武内駿 on 2015/06/01.
//  Copyright (c) 2015年 Syun Takeuchi. All rights reserved.
//  sceneKitテスト

#import "GameViewController.h"

@implementation GameViewController{
    CMMotionManager*_cmm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create a new scene
//    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.dae"];
    SCNScene *scene = [[SCNScene alloc] init];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    cameraNode.camera.zFar=500;
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 100, 0);
    cameraNode.rotation=SCNVector4Make(1.0, 0, 0, -M_PI_2);
    
    //デリゲート設定
    scene.physicsWorld.contactDelegate=self;
    
    //床生成
    SCNNode *floornode=[SCNNode node];
    floornode.geometry=[SCNFloor floor];
    floornode.geometry.firstMaterial.diffuse.contents=[UIColor redColor];
    [scene.rootNode addChildNode:floornode];
    
    //物理エンジン設定
    SCNPhysicsShape *floorshape=[SCNPhysicsShape shapeWithGeometry:floornode.geometry options:nil];
    SCNPhysicsBody *floorbody=[SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:floorshape];
    
    floornode.physicsBody=floorbody;
    
    //壁生成
    [scene.rootNode addChildNode:[self wallbone:SCNVector3Make(0, 0, -50)
                                               :SCNVector4Make(0.0, 0.0, 0.0, 0.0)]];
    [scene.rootNode addChildNode:[self wallbone:SCNVector3Make(0, 0, 50)
                                               :SCNVector4Make(0.0, 0.0, 0.0, 0.0)]];
    [scene.rootNode addChildNode:[self wallbone:SCNVector3Make(30, 0, 0)
                                               :SCNVector4Make(0.0, 1.0, 0.0, M_PI_2)]];
    [scene.rootNode addChildNode:[self wallbone:SCNVector3Make(-30, 0, 0)
                                               :SCNVector4Make(0.0, 1.0, 0.0, M_PI_2)]];
    //玉作成
    SCNNode *spnode =[SCNNode node];
    spnode.geometry=[SCNSphere sphereWithRadius:3];
    spnode.geometry.firstMaterial.diffuse.contents=[UIColor blueColor];
    spnode.position=SCNVector3Make(0.0, 10.0, 0.0);
    [scene.rootNode addChildNode:spnode];
    spnode.name=@"sp";
    
    //物理エンジン設定
    SCNPhysicsShape *spshape=[SCNPhysicsShape shapeWithGeometry:spnode.geometry options:nil];
    SCNPhysicsBody *spbody=[SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:spshape];
    //バウンド
    spbody.restitution=0.1;
    spbody.mass=0.1;
    spnode.physicsBody=spbody;
    
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    //全体ライトオン
    scnView.autoenablesDefaultLighting=YES;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = NO;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
        _cmm=[[CMMotionManager alloc] init];
    //使用条件確認
    if (!_cmm.accelerometerAvailable) {
        NSLog(@"加速度センサー使用不可");
        return;
    }
    //設定（センサーの取得間隔（病
    _cmm.accelerometerUpdateInterval=0.1;
    
    //加速度センサー受信開始
    NSOperationQueue *que=[NSOperationQueue currentQueue];
    
    //ハンドラを指定
    CMAccelerometerHandler hnd =^(CMAccelerometerData *AccelerometerData, NSError *error){
        //センサー値取得
        CMAcceleration ca= AccelerometerData.acceleration;

        
        [spbody applyForce:SCNVector3Make(ca.x*1.5, 0.0, -ca.y*1.5) impulse:YES];
        
    };
    //加速度の取得開始
    [_cmm startAccelerometerUpdatesToQueue:que withHandler:hnd];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
//    SCNView *scnView = (SCNView *)self.view;
//    
//    // check what nodes are tapped
//    CGPoint p = [gestureRecognize locationInView:scnView];
//    NSArray *hitResults = [scnView hitTest:p options:nil];
//    
//    // check that we clicked on at least one object
//    if([hitResults count] > 0){
//        // retrieved the first clicked object
//        SCNHitTestResult *result = [hitResults objectAtIndex:0];
//        
//        // get its material
//        SCNMaterial *material = result.node.geometry.firstMaterial;
//        
//        // highlight it
//        [SCNTransaction begin];
//        [SCNTransaction setAnimationDuration:0.5];
//        
//        // on completion - unhighlight
//        [SCNTransaction setCompletionBlock:^{
//            [SCNTransaction begin];
//            [SCNTransaction setAnimationDuration:0.5];
//            
//            material.emission.contents = [UIColor blackColor];
//            
//            [SCNTransaction commit];
//        }];
//        
//        material.emission.contents = [UIColor redColor];
//        
//        [SCNTransaction commit];
//    }
}
//壁生成
-(SCNNode*)wallbone:(SCNVector3)pos :(SCNVector4)rot{
    SCNNode *wall1=[SCNNode node];
    wall1.geometry=[SCNBox boxWithWidth:100 height:30 length:1 chamferRadius:0];
    
    wall1.geometry.firstMaterial.diffuse.contents=[UIColor whiteColor];
    wall1.position=pos;
    wall1.rotation=rot;
    wall1.name=@"wall";

    //物理エンジン設定
    SCNPhysicsShape *wallshape=[SCNPhysicsShape shapeWithGeometry:wall1.geometry options:nil];
    SCNPhysicsBody *wallbody=[SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:wallshape];
    //バウンド
    wallbody.restitution=0.1;
    //カテゴリビットマスク
    wallbody.categoryBitMask=2;
    wall1.physicsBody=wallbody;
    return wall1;
}
//衝突
-(void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact{
    NSArray* col=@[[UIColor redColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor purpleColor],[UIColor lightGrayColor]];
//    NSLog(@"A %@,B %@",contact.nodeA.name,contact.nodeB.name);
//    NSLog(@"%@,%ld",contact.nodeB.name,(long)contact.nodeB.categoryBitMask);
    
    if ([contact.nodeB.name isEqualToString:@"wall"]) {
        contact.nodeA.geometry.firstMaterial.diffuse.contents=col[arc4random_uniform(col.count)];
    }else if ([contact.nodeA.name isEqualToString:@"wall"]) {
        contact.nodeB.geometry.firstMaterial.diffuse.contents=col[arc4random_uniform(col.count)];
    }

//contact.nodeA.geometry.firstMaterial.diffuse.contents=
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
