# STTextView
##我们知道iOS自带的UITextView基本很难满足我们的日常使用。我项目中textView是继承与UITextview的，自定义了一个TextView，主要实现的以下功能。
1. 添加placeHolder
2. 高度自适应
3. 可以设置行间距
4. 支持xib
***
#####其实实现起来也是很简单，但是非常的实用。
######一. 先看一下头文件
```
@interface STTextView : UITextView
/** 占位文字 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位文字颜色 */
@property (nonatomic, strong) UIColor *placeholderColor;
//行间距 
@property (nonatomic, assign) CGFloat verticalSpacing;
/**设置最大高度*/
@property (nonatomic, assign) CGFloat maxHeight;
/**设置最小高度*/
@property (nonatomic, assign) CGFloat minHeight;
/**是不是自适应高度，默认为YES*/
@property (nonatomic, assign) BOOL isAutoHeight;
@property (nonatomic, copy) void(^textDidChangedBlock)(NSString * text);
@property (nonatomic, copy) void (^textViewAutoHeight)(CGFloat textHeight);
@end
```
应该是一目了然的吧。
######二. 看一下实现过程
1. 这里我是用的是一个`UILabel`来充当占位符，控制其隐藏和显示达到效果。其实还可以通过重写draw方法，进行绘制placeHolder。这里考虑到实际使用过程中，会出现占位符很长，出现换行的情况，使用一个Label可能会更加方便，如下图这种情况：

![兼容占位符很长的情况](http://upload-images.jianshu.io/upload_images/1663049-00df4f1476b80932.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2.占位Label的坐标其实还是很讲究的
我们知道默认的UITextView会有一个默认的边距为`textContainerInset =UIEdgeInsetsMake (8, 0, 8, 0)`,所以设置placeHolder坐标应该考虑到这一点，否则像我这种有点强迫症的人看着很不舒服。我解决方案是添加`@property (nonatomic, assign) UIEdgeInsets placeHolderLabelInsets;`属性，重写`textContainerInset`属性，代码如下：
```
#pragma mark ---setter
- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset{
    //调整text内容边距
    [super setTextContainerInset:textContainerInset];
    self.placeHolderLabelInsets = UIEdgeInsetsMake(textContainerInset.top, textContainerInset.left + 2, textContainerInset.bottom, textContainerInset.right + 2);
    [self setNeedsLayout];
}
```
这样我们就可以自由设置文字边距，而不用再特意去调整placeHoler的坐标了，看一下实际效果图:
1. `tv.textContainerInset = UIEdgeInsetsZero`
![1.边距都为零时候.png](http://upload-images.jianshu.io/upload_images/1663049-3f6ee88fc52fcca3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
2. `textContainerInset默认值`
![边距为默认值时候](http://upload-images.jianshu.io/upload_images/1663049-0b278df0703fb5af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
3. 设置间距`tv.textContainerInset = UIEdgeInsetsMake(15, 10, 15, 10);`
![UIEdgeInsetsMake(15, 10, 15, 10)](http://upload-images.jianshu.io/upload_images/1663049-7c9baa3fe059faeb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这样使用起来就简单多了吧。
3.有一点需要注意的是 使用系统默认键盘时候，应处理一下待选字体，否则会出现输入时候自动把待选字体带进输入框，体验很差，因为待选文字时候也会进入监听方法，这时候我们需要判断有没有待选文字，
```
if(self.markedTextRange == nil){
        //没有候选字符
        [self st_setAttributedString];
        self.textDidChangedBlock ? self.textDidChangedBlock(self.text) : nil;
    };
```
`self.markedTextRange == nil` 进行处理即可
4.当设置行间距的删除文字的时候，我们应该保持光标位置，否则用户删除中间字体的时候，会不断跳到最后边，如下图：
![光标不准](http://upload-images.jianshu.io/upload_images/1663049-bed09ecdcd4f597f.gif?imageMogr2/auto-orient/strip)
解决这个问题很简单 只需要 记录一下光标位置，重新设置一下即可
```
NSRange range = self.selectedRange;
self.attributedText = [[NSAttributedString alloc]initWithString:self.text attributes:[self attrs]];
 self.selectedRange = range;
```
如下图：
![光标修复](http://upload-images.jianshu.io/upload_images/1663049-d93b4fc6832692a6.gif?imageMogr2/auto-orient/strip)
基本上这都是实际使用中需要注意到的问题，其实代码什么的都挺简单。

看一下实际使用效果吧：
![实际使用效果](http://upload-images.jianshu.io/upload_images/1663049-631fb8cb7158d9ac.gif?imageMogr2/auto-orient/strip)
希望能够帮助到大家吧，`demo`已上传到[我的github](https://github.com/strivever/STTextView.git)，下载拖进工程即可使用，如果使用中有什么问题请及时与我联系。
