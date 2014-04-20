westpac-quickpay
================

Personal app to quickly make payments via Westpac NZ.

Not really for anyone to use, just me because I hate logging in and making payments all the time. It should be easier.

## Settings
This only has to be done once

![Demo](https://raw.githubusercontent.com/snikch/westpac-quickpay/master/settings.gif)

## Payments

![Demo](https://raw.githubusercontent.com/snikch/westpac-quickpay/master/payments.gif)

Notes: I had to hack a part of `NJKWebViewProgress.m` (see Pods). If you want this to work, you’ll need to remove anything to do with iframes in the middle of `- (void)webViewDidFinishLoad:(UIWebView *)webView`
