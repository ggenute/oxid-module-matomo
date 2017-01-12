[{*
 * ___MODULE___
 * Copyright (C) ___YEAR___  ___COMPANY___
 * info:  ___EMAIL___
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @author      bestlife AG <oxid@bestlife.ag>
 * @author      Klaus Weidenbach
 * @author      Rafael Dabrowski
 * @author      Marat Bedoev
 * @link        http://www.bestlife.ag
 *
 * @license     GPLv3
 *}]
[{$smarty.block.parent}]
[{assign var="piwikdebug" value=$oViewConf->piwikdebug()}]
<!-- Piwik Code included through bla-piwik -->
[{capture name="piwikscript"}]
    var _paq = _paq || [];
    [{if $piwikdebug}]_paq.push(['setDoNotTrack', false]);[{/if}]

    [{* User ID, available since Piwik >= 2.7.0 *}]
    [{if $oViewConf->getEnableUserID() && $oxcmp_user}]
        [{* TODO: replace somesalt with a shop unique one or from module settings *}]
        _paq.push(['setUserId', '[{$oxcmp_user->oxuser__oxcustnr->value}]']);
    [{/if}]
    [{* general tracking stuff *}]
    _paq.push(['setDocumentTitle', '[{$oViewConf->getDocumentTitle($oView)}]']);

    [{* First Referrer Conversion Attribution, available since Piwik >= 1.2.0 *}]
    [{if $oViewConf->getFirstReferrerConv()}]
        _paq.push(['setConversionAttributionFirstReferrer', true]);
    [{/if}]

    [{ $oViewConf->addPiwikParamMapVisit() }][{*Additional configured custom variables visit-scope*}]
    [{ $oViewConf->addPiwikParamMapPage() }][{*Additional configured custom variables page-scope*}]

    [{* Ecommerce tracking *}]
    [{if $oView->getClassName() == "alist"}]
        [{* category *}]
        _paq.push(['setEcommerceView', false, false, '[{$oView->getTitle()|htmlspecialchars_decode}]']);


    [{elseif $oView->getClassName() == "details"}]
        [{* details page *}]
        [{assign var=category value=$oDetailsProduct->getCategory()}]
        _paq.push(['setEcommerceView','[{$oDetailsProduct->oxarticles__oxartnum->value}]','[{$oDetailsProduct->oxarticles__oxtitle->value|htmlspecialchars_decode}]','[{$category->oxcategories__oxtitle->value|htmlspecialchars_decode}]']);
    [{/if}]

    [{* newsletter goals *}]
    [{if $oView->getClassName() == "account_newsletter" }][{* Viewed account newsletter settings page *}]
        [{if $oView->getSubscriptionStatus() == 0}]
            _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('NewsletterAcc') }]", "page"]);
        [{elseif $oView->getSubscriptionStatus() == 1}]
            [{* enabled newsletter in account settings *}]
            _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('NewsletterAccOn') }]", "page"]);
        [{elseif $oView->getSubscriptionStatus() == -1}]
            [{* disabled newsletter in account settings *}]
            _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('NewsletterAccOff') }]", "page"]);
        [{/if}]
    [{elseif $oView->getClassName() == "newsletter"}][{* Newsletter subscription page *}]

        [{* enable goal tracking if configured *}]
        [{if $oView->getNewsletterStatus() == 2 && $oViewConf->getPiwikNlgoalid() > 0}]
            _paq.push(['trackGoal', [{$piwik_NewletterGoal}]]);
        [{/if}]

        [{* Custom Variable: Detailed newsletter registration tracking if configured *}]
        [{if $piwik_CustomIndexNewsletter > 0}]

            [{* Customer visited newsletter registration form *}]
            [{if $oView->getNewsletterStatus() == 4 || !$oView->getNewsletterStatus()}]
                _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('Newsletter4') }]", "page"]);

                [{* Customer submits newsletter registration form *}]
            [{elseif $oView->getNewsletterStatus() == 1}]
                _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('Newsletter1') }]", "page"]);

                [{* Customer confirmed double-opt-in *}]
            [{elseif $oView->getNewsletterStatus() == 2}]
                _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('Newsletter2') }]", "page"]);

                [{* Customer submits newsletter unsubscribe form *}]
            [{elseif $oView->getNewsletterStatus() == 3}]
                _paq.push(['setCustomVariable', [{$piwik_CustomIndexNewsletter}], "[{ $oViewConf->getPiwikText('Newsletter') }]", "[{ $oViewConf->getPiwikText('Newsletter3') }]", "page"]);
            [{/if}]
        [{/if}]

        [{* Custom Variable: Payment method tracking if configured *}]
    [{elseif $oView->getClassName() == "order" && $oViewConf->getPiwikCustomIndexPayment() > 0}]
        [{assign var="payment" value=$oView->getPayment() }]
        _paq.push(['setCustomVariable',[{$oViewConf->getPiwikCustomIndexPayment()}], '[{ $oViewConf->getPiwikText('Payment') }]', '[{ $payment->oxpayments__oxdesc->value }]', 'visit']);

        [{* Ecommerce conversion thank you page *}]
    [{elseif $oView->getClassName() == "thankyou"}]
        [{foreach key=basketindex from=$basket->getContents() item=item name=basketContents}]
            [{assign var=product value=$item->getArticle()}]
            [{assign var=itemprice value=$item->getUnitPrice()}]
            [{assign var=category value=$product->getCategory()}]
            _paq.push(['addEcommerceItem', '[{$product->oxarticles__oxartnum->value}]', '[{$item->getTitle()|htmlspecialchars_decode}]', '[{$category->oxcategories__oxtitle->value|htmlspecialchars_decode}]',[{$itemprice->getBruttoPrice()}],[{$item->getAmount()}] ]);
        [{/foreach}]

        [{assign var=oprice value=$order->getOrderTsProtectionPrice()}]
        [{assign var=delPrice value = $order->getOrderDeliveryPrice()}]
        [{assign var=payPrice value = $order->getOrderPaymentPrice()}]
        [{assign var=wrapPrice value = $order->getOrderWrappingPrice()}]
        _paq.push(['trackEcommerceOrder',
        '[{$order->oxorder__oxordernr->value}]',
        [{$order->getTotalOrderSum()}],
        [{$basket->getDiscountedProductsBruttoPrice()}],
        ([{$order->oxorder__oxartvatprice1->value}]+[{$order->oxorder__oxartvatprice2->value}]),
        ([{$delPrice->getBruttoPrice()}]+[{$payPrice->getBruttoPrice()}]+[{$wrapPrice->getBruttoPrice()}]),
        [{$order->oxorder__oxdiscount->value}]
        ]);
    [{/if}]

    [{* product search *}]
    [{if $oView->getClassName() == "search"}]
        _paq.push(['trackSiteSearch', '[{$oView->getSearchParamForHtml()}]', false,[{$oView->getArticleCount()}]]);
    [{else}]
        _paq.push(['trackPageView']);
    [{/if}]



    [{* Ecommerce add item to basket and Ecommerce view basket *}]
    [{if $oxcmp_basket->isNewItemAdded() || $oView->getClassName() == "basket" }]
        [{foreach key=basketindex from=$oxcmp_basket->getContents() item=item name=basketContents}]
            [{assign var="product" value=$item->getArticle()}]
            [{assign var=itemprice value=$item->getUnitPrice()}]
            [{assign var=category value=$product->getCategory()}]
            _paq.push(['addEcommerceItem',
            '[{$product->oxarticles__oxartnum->value}]',
            '[{$item->getTitle()|htmlspecialchars_decode}]',
            '[{$category->oxcategories__oxtitle->value|htmlspecialchars_decode}]',
            [{$itemprice->getBruttoPrice()}],
            [{$item->getAmount()}]
            ]);
        [{/foreach}]
        _paq.push(['trackEcommerceCartUpdate',[{$oxcmp_basket->getBruttoSum()}]   ]);
    [{/if}]


    _paq.push(['enableLinkTracking']);

    [{* JavaScript Error Tracking, available since Piwik >= 2.2.0 *}]
    [{if $oViewConf->getPiwikEnableJSError()}]
        _paq.push(['enableJSErrorTracking']);
    [{/if}]

    (function () {
    var u = document.location.protocol + "//[{$oViewConf->getPiwikUrl()|replace:'http://':''|replace:'https://':''}]/";
    _paq.push(['setTrackerUrl', u + 'piwik.php']);
    _paq.push(['setSiteId', [{$oViewConf->getPiwikPageid()}]]);
    var d = document, g = d.createElement('script'), s = d.getElementsByTagName('script')[0];
    g.type = 'text/javascript';
    g.defer = true;
    g.async = true;
    g.src = u + 'piwik.js';
    s.parentNode.insertBefore(g, s);
    })();
[{/capture}]
[{if $piwikdebug}]
    <pre>class: [{$oView->getClassName()}]<br/>[{$smarty.capture.piwikscript|replace:';':';<br/>'}]</pre>
    <script type="text/javascript">[{$smarty.capture.piwikscript}]</script>
[{else}]
    <script type="text/javascript">[{$smarty.capture.piwikscript|strip}]</script>
[{/if}]

<!-- End Piwik Code -->