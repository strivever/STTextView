//
//  STTextView.m
//  STTextView
//
//  Created by StriEver on 17/5/22.
//  Copyright © 2017年 StriEver. All rights reserved.
//

#import "STTextView.h"
#import "UIView+Extension.h"
#define DefaultColor [UIColor grayColor]
@interface STTextView ()
@property (nonatomic, strong) UILabel * placeHolderLabel;
@property (nonatomic, assign) UIEdgeInsets placeHolderLabelInsets;
@end
@implementation STTextView
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUpView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpView];
    }
    return self;
}
#pragma mark ---setter
- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset{
    //调整text内容边距
    [super setTextContainerInset:textContainerInset];
    self.placeHolderLabelInsets = UIEdgeInsetsMake(textContainerInset.top, textContainerInset.left + 2, textContainerInset.bottom, textContainerInset.right + 2);
    [self setNeedsLayout];
}
- (void)setText:(NSString *)text{
    [super setText:text];
    [self textViewDidChange:nil];
}
- (void)setFont:(UIFont *)font{
    [super setFont:font];
    self.placeHolderLabel.font  = font;
}
- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.placeHolderLabel.text = _placeholder;
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    _placeholderColor = placeholderColor;
    self.placeHolderLabel.textColor = _placeholderColor;
}
- (void)setIsAutoHeight:(BOOL)isAutoHeight{
    _isAutoHeight = isAutoHeight;
    if (_isAutoHeight) {
        self.scrollEnabled = NO;
    }
}
- (void)setPlaceHolderLabelInsets:(UIEdgeInsets)placeHolderLabelInsets{
    _placeHolderLabelInsets = placeHolderLabelInsets;
    [self layoutSubviews];
}

- (void)resetPlaceHolderLabelState{
    if ([self hasText]) {
        self.placeHolderLabel.hidden = YES;
    }else{
        self.placeHolderLabel.hidden = NO;
    }
}
#pragma mark ---UI
- (void)setUpView{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    _placeHolderLabel = [UILabel new];
    _placeHolderLabel.textColor = self.placeholderColor ? self.placeholderColor : DefaultColor;
    _placeHolderLabel.text = self.placeholder;
    _placeHolderLabel.font = self.font;
    _placeHolderLabel.numberOfLines = 0;
    [self addSubview:_placeHolderLabel];
    
    [self setPlaceHolderLabelInsets:UIEdgeInsetsMake(8, 2, 8, 2)];
    self.font = [UIFont systemFontOfSize:17];
    self.isAutoHeight = YES;
    self.maxHeight = 300;
    self.minHeight = 30;
    NSLog(@"self.textContainerInset--->%@\n---------->%@\nself.scrollIndicatorInsets----------->%@",NSStringFromUIEdgeInsets(self.textContainerInset),NSStringFromUIEdgeInsets(self.contentInset),NSStringFromUIEdgeInsets(self.scrollIndicatorInsets));
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _placeHolderLabel.frame = CGRectMake(_placeHolderLabelInsets.left, _placeHolderLabelInsets.top, self.frame.size.width - _placeHolderLabelInsets.left - _placeHolderLabelInsets.right, 0);
    [_placeHolderLabel sizeToFit];
    if (_placeHolderLabel.hidden == NO && self.isAutoHeight) {
        CGFloat placeHolderHeight = _placeHolderLabel.height + (_placeHolderLabelInsets.top + _placeHolderLabelInsets.bottom);
        if (placeHolderHeight > self.height) {
            self.height = placeHolderHeight;
        }
    }
    
}

#pragma mark ---NSNotificationEvent
- (void)textViewDidEndEditing:(NSNotification *)notification{
    
}
- (void)textViewDidChange:(NSNotification *)notification{
    if (self.text.length == 0) {
        self.placeHolderLabel.text = _placeholder;
        self.placeHolderLabel.hidden = NO;
        [self setNeedsLayout];
    }else{
        self.placeHolderLabel.hidden = YES;
    }
    if(self.markedTextRange == nil){
        //没有候选字符
        [self st_setAttributedString];
        self.textDidChangedBlock ? self.textDidChangedBlock(self.text) : nil;
    };
    
    [self st_autoHeight];
    [self resetPlaceHolderLabelState];
    
}

#pragma mark --- function
//设置属性字符串
- (void)st_setAttributedString{
    //设置了间距
    if (self.verticalSpacing > 0) {
        if (self.text.length > 0) {
            NSRange range = self.selectedRange;
            self.attributedText = [[NSAttributedString alloc]initWithString:self.text attributes:[self attrs]];
            self.selectedRange = range;
        }
    }
}
- (NSDictionary *)attrs{
    if (self.verticalSpacing > 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = self.verticalSpacing;// 字体的行间距
        NSDictionary *attributes = @{NSFontAttributeName:self.font,NSParagraphStyleAttributeName:paragraphStyle};
        return attributes;
    }
    return nil;
}

- (void)st_autoHeight{
    //是否开启
    CGFloat height = 0;;
    if (self.isAutoHeight) {
        if (self.text.length == 0){
            height = self.minHeight;
            self.height = self.minHeight;
            //高度变化
            self.textViewAutoHeight ? self.textViewAutoHeight(self.height) : nil;
        }else{
            height = [self att_height];
            if (height != self.height) {
                if (height > self.maxHeight) {
                    self.height = self.maxHeight;
                    self.scrollEnabled = YES;
                }else if (height < self.minHeight){
                    self.height = self.minHeight;
                    self.scrollEnabled = NO;
                }else{
                    self.scrollEnabled = NO;
                    self.height = height;
                }
                //高度变化
                self.textViewAutoHeight ? self.textViewAutoHeight(self.height) : nil;
            }
        }
    }
}

//计算高度
- (CGFloat)att_height{
    @autoreleasepool{
        UITextView * tempTV = [UITextView new];
        tempTV.font = self.font;
        tempTV.textContainerInset = self.textContainerInset;
        if ([self attrs]) {
            tempTV.attributedText = [[NSAttributedString alloc]initWithString:self.text attributes:[self attrs]];
        }else{
            tempTV.text = self.text;
        }
        CGFloat height =  [tempTV sizeThatFits:CGSizeMake(self.width, MAXFLOAT)].height;
        return height;
    }
}
@end
