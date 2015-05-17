//
//  InviteView.m
//  Hydro
//
//  Created by NIX on 14/12/27.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "InviteView.h"

@interface InviteView()

@end


@implementation InviteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    CGFloat logoSize = 36.0;

    //NSNumber *leftInset = @20;
    //NSNumber *rightInset = @30;

    CGFloat fontSize = 18.0;

#pragma mark - Invite Text Filed

    UILabel *inviteTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    inviteTextLabel.font = [UIFont fontWithName:@"Avenir-Light" size:fontSize];
    inviteTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    inviteTextLabel.text = NSLocalizedString(@"Invite Friend to", nil);
    [self addSubview:inviteTextLabel];

    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logoSize, logoSize)];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.image = [UIImage imageNamed:@"logo"];
    [self addSubview:logoImageView];

    UILabel *hydroLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hydroLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:fontSize];
    hydroLabel.textColor = [UIColor whiteColor];
    hydroLabel.text = NSLocalizedString(@"Hydro", nil);
    [self addSubview:hydroLabel];

    UIView *helperView = [[UIView alloc] init];
    [self addSubview:helperView];

    {
        inviteTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        hydroLabel.translatesAutoresizingMaskIntoConstraints = NO;
        helperView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *viewsDictionary = @{
                                          @"inviteTextLabel":inviteTextLabel,
                                          @"logoImageView":logoImageView,
                                          @"hydroLabel":hydroLabel,
                                          };

        NSNumber *topOffset = @40;
        NSNumber *logoWidth = @(logoSize);
        NSNumber *logoHeight = @(logoSize);
        NSNumber *labelHeight = @(logoSize);


        NSArray *constraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[inviteTextLabel]-[logoImageView(logoWidth)]-[hydroLabel]-(>=0)-|"
                                                                       options:0
                                                                       metrics:@{@"logoWidth": logoWidth,
                                                                                 }
                                                                         views:viewsDictionary];


        NSArray *constraintV1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topOffset)-[inviteTextLabel(labelHeight)]"
                                                                        options:0
                                                                        metrics:@{@"topOffset": topOffset,
                                                                                  @"labelHeight": labelHeight,
                                                                                  }
                                                                          views:viewsDictionary];

        NSArray *constraintV2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topOffset)-[logoImageView(logoHeight)]"
                                                                        options:0
                                                                        metrics:@{@"topOffset": topOffset,
                                                                                  @"logoHeight": logoHeight,
                                                                                  }
                                                                          views:viewsDictionary];

        NSArray *constraintV3 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topOffset)-[hydroLabel(labelHeight)]"
                                                                        options:0
                                                                        metrics:@{@"topOffset": topOffset,
                                                                                  @"labelHeight": labelHeight,
                                                                                  }
                                                                          views:viewsDictionary];




        NSLayoutConstraint *helpConstraint1 = [NSLayoutConstraint constraintWithItem:helperView
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:inviteTextLabel
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1
                                                                            constant:0];

        NSLayoutConstraint *helpConstraint2 = [NSLayoutConstraint constraintWithItem:helperView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:hydroLabel
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:0];

        NSLayoutConstraint *helpConstraint3 = [NSLayoutConstraint constraintWithItem:helperView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1
                                                                            constant:0];

        [self addConstraints:constraintH];
        [self addConstraints:constraintV1];
        [self addConstraints:constraintV2];
        [self addConstraints:constraintV3];
        [self addConstraint:helpConstraint1];
        [self addConstraint:helpConstraint2];
        [self addConstraint:helpConstraint3];
    }

#pragma mark - Email Text Filed

    _emailTextField = [[SAMTextField alloc] initWithFrame:CGRectZero];
    [_emailTextField setBackground:[UIImage imageNamed:@"EM"]];
    _emailTextField.textColor = [UIColor whiteColor];
    _emailTextField.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    _emailTextField.textAlignment = NSTextAlignmentCenter;
    _emailTextField.contentMode = UIViewContentModeScaleAspectFit;
    _emailTextField.adjustsFontSizeToFitWidth = YES;
    _emailTextField.minimumFontSize = 12;
    _emailTextField.tintColor = [UIColor whiteColor];
    _emailTextField.returnKeyType = UIReturnKeyDone;

    NSDictionary *attrsDictionary = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:22.0],
                                      NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.8]
                                      };

    NSAttributedString *attrEmailString = [[NSAttributedString alloc] initWithString:@"Email"
                                                                          attributes:attrsDictionary];

    _emailTextField.attributedPlaceholder = attrEmailString;

    _emailTextField.textEdgeInsets = UIEdgeInsetsMake(0.0f, 40.0f, 5.0f, 10.0f);

    [self addSubview:_emailTextField];

    {
        _emailTextField.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *viewsDictionary = @{
                                          @"inviteTextLabel":inviteTextLabel,
                                          @"emailTextField":_emailTextField,
                                          };

        NSArray *constraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[emailTextField(240)]-(>=0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];

        NSArray *constraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[inviteTextLabel]-(60)-[emailTextField(30)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];

        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_emailTextField
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1
                                                                            constant:0];
        
        [self addConstraints:constraintH];
        [self addConstraints:constraintV];
        [self addConstraint:constraint];
    }

#pragma mark - Invite Button

    _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inviteButton setBackgroundImage:[UIImage imageNamed:@"Button"] forState:UIControlStateNormal];
    [_inviteButton setTitle:NSLocalizedString(@"Send invitation", nil) forState:UIControlStateNormal];
    _inviteButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:fontSize];
    [self addSubview:_inviteButton];

    {
        _inviteButton.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *viewsDictionary = @{
                                          @"emailTextField":_emailTextField,
                                          @"inviteButton":_inviteButton,
                                          };

        NSArray *constraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[inviteButton(240)]-(>=0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];

        NSArray *constraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[emailTextField]-(60)-[inviteButton(60)]-(>=0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];

        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_inviteButton
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1
                                                                       constant:0];

        [self addConstraints:constraintH];
        [self addConstraints:constraintV];
        [self addConstraint:constraint];
    }

}

@end
