import Photos
import SnapKit
import Foundation
import Network
import UIKit
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import MessageUI

class UseTermsViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let bodyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        // Configura a UIScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        title = "Terms of Use"
        
        bodyLabel.text =
        """
        Last Updated: January 24, 2024

        PLEASE READ THIS TERMS OF SERVICE AGREEMENT (THE “TERMS”) CAREFULLY. SECRET GALLERY SOFTWARE, INC. (“SECRET GALLERY” OR “WE” OR “US") MAKES AVAILABLE BY ACCESSING OR USING THIS WEBSITE AND ANY OTHER WEBSITES OF SECRET GALLERY (COLLECTIVELY, THE “WEBSITE”), AND THE SERVICE AND APPLICATIONS DESCRIBED IN THESE TERMS. BY ACCESSING OR USING THE WEBSITE IN ANY WAY, INCLUDING USING THE SERVICES AND RESOURCES AVAILABLE OR ENABLED VIA THE WEBSITE OR APPLICATIONS (THE “SERVICE”), DOWNLOADING THE SECRET GALLERY SOFTWARE APPLICATIONS FOR MOBILE DEVICES (EACH, AN “APPLICATION”, AND COLLECTIVELY, THE “APPLICATIONS”), COMPLETING THE REGISTRATION PROCESS, AND/OR MERELY BROWSING THE WEBSITE, YOU REPRESENT THAT (1) YOU HAVE READ, UNDERSTAND, AND AGREE TO BE BOUND BY THE TERMS, (2) YOU ARE OF LEGAL AGE TO FORM A BINDING CONTRACT WITH SECRET GALLERY, AND (3) YOU HAVE THE AUTHORITY TO ENTER INTO THE TERMS PERSONALLY OR ON BEHALF OF THE COMPANY YOU HAVE NAMED AS THE CUSTOMER, AND TO BIND THAT COMPANY TO THE TERMS. THE TERM “YOU” REFERS TO THE INDIVIDUAL OR LEGAL ENTITY, AS APPLICABLE, IDENTIFIED AS THE CUSTOMER WHEN YOU REGISTERED ON THE WEBSITE. IF YOU DO NOT AGREE TO BE BOUND BY THE TERMS, YOU MAY NOT ACCESS OR USE THIS WEBSITE OR THE SERVICE.

        IF YOU SUBSCRIBE TO THE SERVICES FOR A TERM (THE “INITIAL TERM”), THEN THE TERMS WILL BE AUTOMATICALLY RENEWED FOR ADDITIONAL PERIODS OF THE SAME DURATION AS THE INITIAL TERM AT SECRET GALLERY’S THEN-CURRENT FEE FOR SUCH SERVICES UNLESS YOU DECLINE TO RENEW YOUR SUBSCRIPTION IN ACCORDANCE WITH SECTION 6.5 BELOW.

        THE TERMS OF USE REQUIRE THE USE OF ARBITRATION ON AN INDIVIDUAL BASIS TO RESOLVE DISPUTES, RATHER THAN JURY TRIALS OR CLASS ACTIONS, AND ALSO LIMIT THE REMEDIES AVAILABLE TO YOU IN THE EVENT OF A DISPUTE.

        PLEASE NOTE THAT THE TERMS ARE SUBJECT TO CHANGE BY SECRET GALLERY IN ITS SOLE DISCRETION AT ANY TIME. When changes are made, SECRET GALLERY will make a new copy of the Terms of Service available at the Website. We will also update the “Last Updated” date at the top of the Terms. If we make any material changes, and you have registered to use the Service, we will also send an e-mail to you at the last e-mail address you provided to us pursuant to the Terms. Any changes to the Terms will be effective immediately for new users of the Website or Service and for any other users who expressly agree to them. Otherwise, such changes will be effective thirty (30) days after posting of notice of such changes on the Website for existing users, provided that any material changes shall be effective for users who have a registered account on the Website (each, a “Registered User”) upon the earlier of thirty (30) days after posting of notice of such changes on the Website or thirty (30) days after dispatch of an e-mail notice of such changes to Registered Users. SECRET GALLERY may require you to agree to the updated Agreement in a manner specified before further use of the Website or the Service is permitted. If you do not agree to any change(s) after receiving a notice of such change(s), you shall stop using the Website and/or the Service. Otherwise, your continued use of the Website and/or Service constitutes your acceptance of such change(s). PLEASE REGULARLY CHECK THE WEBSITE TO VIEW THE THEN-CURRENT AGREEMENT.

        SECRET GALLERY Service Description.
        SECRET GALLERY offers a variety of tools, applications, web services and widgets that allows users to capture, control and manage data and messages on your electronic devices. You can use the Service to intercept messages, move files from one storage location on your device to a restricted storage location, and create backup copies of your data. The Service further includes a virtual private network service (the “VPN Service”) which provides private and secure data transmission. Finally, the Service offers telephony and text messaging services, including the ability to send and receive text messages, create separate phone lines, and voicemail (the “Telephony Service”).

        Use of the Service and SECRET GALLERY Properties.
        SECRET GALLERY and its licensors own all rights, title, and interest in the Application, the Software, the Website, the Service, and the information and content available on or through the foregoing (collectively, the “SECRET GALLERY Properties”). The SECRET GALLERY Properties are protected by copyright laws throughout the world. Subject to the Terms, SECRET GALLERY grants you a limited license to reproduce portions of the SECRET GALLERY Properties for the sole purpose of using the SECRET GALLERY Properties for your personal, non-commercial purposes. Unless otherwise specified by SECRET GALLERY in a separate license, your right to use any SECRET GALLERY Properties is subject to the Terms. SECRET GALLERY and its licensors reserve all rights not granted in these Terms.

        2.1 Application License.

        Application License. Subject to your compliance with the Terms, SECRET GALLERY grants you a limited, non-exclusive, non-transferable, non-sublicensable, revocable license to download, install and use a copy of the Application on a single mobile device or computer that you own or control and to run such copy of the Application solely for your own personal use. Furthermore, with respect to any Application accessed through or downloaded from the Apple App Store (an “App Store Sourced Application”), you will only use the App Store Sourced Application (i) on an Apple-branded product that runs the iOS (Apple’s proprietary operating system) and (ii) as permitted by the “Usage Rules” set forth in the Apple App Store Terms of Service.

        2.2 SECRET GALLERY Software.

        Use of any software and associated documentation, other than the Application, that is made available via the Website or the Service (“Software”) is governed by the Terms. Any copying or redistribution of the Software is prohibited, including any copying or redistribution of the Software to any other server or location, redistribution or use on a service bureau basis. If the Software is a pre-release version, then you are not permitted to use or otherwise rely on the Software for any commercial or production purposes. SECRET GALLERY grants you a non-assignable, non-transferable, non- sublicensable, revocable non-exclusive license to use the Software for the sole purpose of enabling you to use the Service in the manner permitted by the Terms. Some Software may be offered under an open source license that we will make available to you. There may be provisions in the open source license that expressly override some of the Terms.

        2.3 VPN Service.

        VPN Service. The VPN Service has sufficient capacity to accommodate average non-commercial use. However, from time to time during periods of extraordinarily heavy usage of the VPN Service, you may temporarily experience slower service or service unavailability. No such temporary slowdown or unavailability shall constitute a breach or default by SECRET GALLERY of its obligations. SECRET GALLERY reserves the right to temporarily suspend or limit your use of the VPN Service if: (a) your usage level exceeds our average customer use level or otherwise negatively impacts the overall health of the network determined by SECRET GALLERY in its sole and absolute discretion, or (b) you exceed any bandwidth limitations associated with your account. No such suspension or limitation of the VPN Service shall constitute a breach or default by SECRET GALLERY of its obligations.

        2.4 Updates.

        You understand that the SECRET GALLERY Properties are evolving. As a result, SECRET GALLERY may require you to accept updates to the Application or the Software that you have installed on your computer or mobile device. You acknowledge and agree that SECRET GALLERY may update the SECRET GALLERY Properties with or without notifying you. Any updates to the SECRET GALLERY Properties are subject to these Terms. You may need to update third party software from time to time in order to continue using the SECRET GALLERY Properties.

        2.5 Certain Restrictions.

        The rights granted to you in the Terms are subject to the following restrictions: (a) you shall not license, sell, rent, lease, transfer, assign, reproduce, distribute, host or otherwise commercially exploit the SECRET GALLERY Properties, (b) you shall not frame or utilize framing techniques to enclose any SECRET GALLERY trademark or logo (including images, text, page layout or form); (c) you shall not use any metatags or other “hidden text” using SECRET GALLERY’s name or trademarks; (d) you shall not modify, translate, adapt, merge, make derivative works of, disassemble, decompile, reverse compile or reverse engineer any part of the SECRET GALLERY Properties except to the extent the foregoing restrictions are expressly prohibited by applicable law; (e) you shall not attempt or engage in, any potentially harmful acts that are directed against the SECRET GALLERY Properties, including but not limited to violating or attempting to violate any security features of the SECRET GALLERY Properties, using any manual or automated software, devices or other processes (including but not limited to spiders, robots, scrapers, crawlers, avatars, data mining tools or the like) to “scrape” or download data from any SECRET GALLERY Properties, or introducing viruses, worms, or similar harmful code into the SECRET GALLERY Properties; (f) access the SECRET GALLERY Properties in order to build a similar or competitive website, application or service; (g) except as expressly stated herein, no part of the SECRET GALLERY Properties may be copied, reproduced, distributed, republished, downloaded, displayed, posted or transmitted in any form or by any means; (h) you shall not remove or destroy any copyright notices or other proprietary markings contained on or in the SECRET GALLERY Properties; (i) you shall not use the SECRET GALLERY Properties in any manner that could damage, disable, overburden, or impair SECRET GALLERY’s systems or networks, or interfere with any other party’s use and enjoyment of the SECRET GALLERY Properties, including without limitation, by means of overloading, “flooding,” “spamming,” “mail bombing”, or “crashing” the SECRET GALLERY Properties; (j) you may not attempt to gain unauthorized access to any computer systems or networks associated with the SECRET GALLERY Properties; (k) . Any future release, update or other addition to the SECRET GALLERY Properties shall be subject to the Terms. SECRET GALLERY, its suppliers and service providers reserve all rights not granted in the Terms. Any unauthorized use of the SECRET GALLERY Properties terminates the licenses granted by SECRET GALLERY pursuant to the Terms.

        2.6 Third Party Materials.

        As a part of the SECRET GALLERY Properties, you may have access to materials that are hosted by another party. You agree that it is impossible for SECRET GALLERY to monitor such materials and that you access these materials at your own risk.

        2.7 Telephony Services.

        (a) Generally. The Telephony Services enable users to acquire phone numbers during the period for which the applicable fees have been paid. Users may be able to request specific phone numbers, however, SECRET GALLERY does not guarantee that any particular phone number may be available. If a user does not renew their subscription to a particular phone number, SECRET GALLERY reserves the right to immediately, without any grace period, to reclaim such phone number. In the event SECRET GALLERY reclaims any phone number, all associated data, such as call history, text messages and voicemail, may be permanently deleted. You agree that SECRET GALLERY will not be liable for the deletion of any such data.

        (b) Restrictions. We reserve the right to reclaim any phone number from your Account and return that number to the relevant numbering plan if you do not send sufficient traffic over that phone number such that the phone number is unutilized or underutilized, as defined by any local, federal and/or national regulatory agency and/or governmental organization with oversight over the relevant phone number and numbering plan. If we seek to reclaim a phone number from your Account, excluding suspended or trial Accounts, we will send you an email in advance telling you that we are reclaiming the phone number, unless we’re otherwise prevented from doing so by the applicable regulatory agency or governmental organization. We also reserve the right to reclaim phone numbers from Accounts suspend for failure to pay and/or suspended for suspected fraud, and to reclaim phone numbers in free trial Accounts that are utilized for more than thirty (30) days. YOU WILL NOT ATTEMPT TO USE THE TELEPHONY SERVICES OR ALLOW ACCESS TO EMERGENCY, E911 OR 911 SERVICES.

        2.7 My Number Lookup Service; SMS.
        (a) General. This Section 2.7 applies when you use our My Number Lookup service (the “SMS Service”). The SMS Service allows you to send us requests via mobile text message personal information associated with your phone number that we collect from publicly available and commercially available sources and marketing information about our SECRET GALLERY Unlisted service.

        Your carrier&#39;s standard messaging and data rates apply to your initial request message, our confirmation and all subsequent text message correspondence. We do not charge for any content, however, downloadable content may incur additional charges from your cell phone provider. Please contact your wireless carrier for information about your messaging plan. Your carrier may impose message or charge limitations on your account that are outside our control. All charges are billed by and payable to your mobile service provider.

        By requesting to receive marketing text messages from +1 (855) 228-4539 or another number or shortcode provided to you through the SMS Service, you consent to receiving the number of marketing messages specified in the call to action using automated technology on your mobile phone or device. You can unsubscribe at any time from all messages from this number by texting STOP. Your consent to receive text messages is not required to make a purchase.

        You represent that you are the owner or authorized user of the wireless device you use to contact the SMS Service, and that you are authorized to approve the applicable charges.

        We will not be liable for any delays or failures in your receipt of any text messages as delivery is subject to effective transmission from your network operator and processing by your mobile device. Text message services are provided on an AS IS, AS AVAILABLE basis.

        Data we obtain from you in connection with the SMS Service may include your cell phone number, your carrier&#39;s name, and the date, time and content of your messages and other information that you may provide. We will only use this information to provide the SMS Service and other services you request from us, and as otherwise described in these Terms and our Privacy Policy. We do not use any SMS Data about you for any purpose other than to provide it to you when you use the SMS Service, we do not share it with any third parties (except for our service providers as described in our Privacy Policy) and we do not retain it for longer than is necessary provide the SMS Service. Your wireless carrier and other service providers may also collect data about your text message usage, and their practices are governed by their own policies.

        When you provide us information in connection with the SMS Service, you agree to provide accurate, complete, and true information. The SMS Service and the content and materials received through the service are proprietary to us or our licensors, and is for your personal, non-commercial use only. You shall not damage, impair, interfere with or disrupt the SMS Service or its functionality.

        The SMS Service is available only in the United States.

        We reserve the right to alter charges and/or the terms and conditions set forth in this Section 2.7 from time to time. We may suspend or terminate your access to the SMS Service if we believe you are in breach of our terms and conditions. Your access to the SMS Service is also subject to termination in the event that your wireless service terminates or lapses. We may discontinue the SNS Service at any time.

        If you have any questions, email us at privacy@getSECRET GALLERY.com. You can also text the word HELP to the number from which you received our text messages to get additional information about these services. We do not charge for help or info messages; however, your normal carrier rates apply.

        (b) SMS Data Terms. The terms and conditions in this Section 2.7(b) apply to any personal information associated with your phone number and other content that you receive from the SMS Service (“SMS Data”). You agree that you will not:
        1. use any SMS Data for marketing purposes, except to respond to an inquiry, application,
        purchase or transaction;
        2. publish, offer, sell, license, transmit, distribute, or reproduce the SMS Data via any
        means;
        3. use the SMS Data in violation of any applicable law, rule, or regulation (e.g., the
        Telephone Consumer Protection Act, the Fair Credit Reporting Act) or in violation of any
        third party right;
        4. store the SMS Data for purposes other than your own internal, non-commercial purposes
        (storage of the data for resale is expressly prohibited);
        5. cache the SMS Data to avoid additional queries; or
        6. merge the SMS Data with databases or compilations for purposes other than your own
        internal business purposes.
        Additionally, you acknowledge that the SMS Service is not provided by a “consumer reporting agency” as that term is defined in the Fair Credit Reporting Act (“FCRA”) and the SMS Data does not constitute “consumer reports” as defined in the FCRA. Accordingly, the SMS Data may not be used as a factor in determining eligibility for credit, insurance, employment or another purpose in which a consumer report may be used under the FCRA.

        You represent and warrant that you will comply with the terms and conditions set forth in this Section 2.7(b) (“SMS Data Terms”). You acknowledge and agree that (a) the SMS Data is provided to you on an “as is” basis without warranties of any kind; (b) neither SECRET GALLERY nor its SMS Data licensors will be liable to you in any manner in connection with your use of the SMS Data; and (c) you shall indemnify, defend, and hold harmless SECRET GALLERY and its SMS Data licensors from and against all claims, actions, and judgments arising out of your use of the SMS Data. Our SMS Data suppliers shall be third party beneficiaries of these SMS Data Terms and shall have the right to enforce them. These SMS Data Terms are in addition to, and shall not be construed to limit the effect of, any other provision of these Terms.

         

        Registration.
        3.1 Registering Your Account.

        In order to access certain features of the SECRET GALLERY Properties, you may be required to become a Registered User. For purposes of the Terms, a “Registered User” is a user who has registered an account on the Application (“Account”).

        3.2 Registration Data.

        In registering for the Service, you agree to (1) provide true, accurate, current and complete information about yourself as prompted by the Service’s registration form (the “Registration Data”); and (2) maintain and promptly update the Registration Data to keep it true, accurate, current and complete. You represent that you are (1) at least sixteen (16) years old; (2) of legal age to form a binding contract; and (3) not a person barred from using the Service under the laws of the United States, your place of residence or any other applicable jurisdiction. You agree that you shall monitor your Account to restrict use by minors, and you will accept full responsibility for any unauthorized use of the SECRET GALLERY Properties by minors. If you provide any information that is untrue, inaccurate, not current or incomplete, or SECRET GALLERY has reasonable grounds to suspect that such information is untrue, inaccurate, not current or incomplete, SECRET GALLERY has the right to suspend or terminate your Account and refuse any and all current or future use of the SECRET GALLERY Properties (or any portion thereof). You agree not to create an Account using a false identity or information, or on behalf of someone other than yourself. You agree that you shall not have more than one Account per platform at any given time. SECRET GALLERY reserves the right to remove or reclaim any usernames at any time and for any reason, including but not limited to, claims by a third party that a username violates the third party’s rights. You agree not to create an Account or use the SECRET GALLERY Properties if you have been previously removed by SECRET GALLERY, or if you have been previously banned from the Service.

        3.3 Activities Under Your Account.

        You are responsible for all activities that occur under your Account. You may not share your Account or password with anyone, and you agree to (1) notify SECRET GALLERY immediately of any unauthorized use of your password or any other breach of security; and (2) exit from your Account at the end of each session.

        3.4 Necessary Equipment and Software.

        You must provide all equipment and software necessary to connect to the SECRET GALLERY Properties, including but not limited to, a mobile device that is suitable to connect with and use the SECRET GALLERY Properties, in cases where the Service offer a mobile component. You are solely responsible for any fees, including Internet connection or mobile fees, that you incur when accessing the SECRET GALLERY Properties.

        Responsibility for Content.
        4.1 Types of Content.

        You acknowledge that all information, data, text, software, music, sound, photographs, graphics, video, messages, tags and/or other materials accessible through the SECRET GALLERY Properties, whether publicly posted or privately transmitted (“Content”), are the sole responsibility of the party from whom such Content originated. This means that you, and not SECRET GALLERY, are entirely responsible for all Content that you upload, post, e-mail, transmit or otherwise make available (“Make Available”) through SECRET GALLERY Properties (“Your Content”).

        User Conduct.
        As a condition of use, you agree not to use the SECRET GALLERY Properties for any purpose that is prohibited by the Terms or by applicable law. You shall not (and shall not permit any third party) either (a) to take any action or (b) Make Available any Content on or through the Website and the Service that: (i) infringes or violates any patent, trademark, trade secret, copyright, contractual right, right of publicity or other right of any person or entity; (ii) violates any acceptable use or other information technology policy that may apply to your use of any computer system or network; (iii) is unlawful, threatening, abusive, harassing, defamatory, libelous, deceptive, fraudulent, invasive of another’s privacy, tortious, obscene, offensive, or profane; (iv) constitutes unauthorized or unsolicited advertising, junk or bulk e-mail; (v) involves commercial activities and/or sales without SECRET GALLERY’s prior written consent, such as contests, sweepstakes, barter, advertising, or pyramid schemes; (vi) impersonates any person or entity, including any employee or representative of SECRET GALLERY; or (vii) is inappropriate in any other manner that SECRET GALLERY determines in its sole, reasonable discretion.

        Fees and Purchase Terms.
        6.1 General Purpose of Terms: Sale of Service, not Software.

        The purpose of the Terms is for you to secure access to the Services. All fees set forth within and paid by you under the Terms shall be considered solely in furtherance of this purpose. In no way are these fees paid considered payment for the sale, license, or use of SECRET GALLERY’s Software or Application, and, furthermore, any use of SECRET GALLERY’s Software or Application by you in furtherance of the Terms will be considered merely in support of the purpose of the Terms.

        6.2 Payment.

        You agree to pay all fees or charges to your Account in accordance with the fees, charges, and billing terms in effect at the time a fee or charge is due and payable. SECRET GALLERY collects payments through a limited number of payment services (“Payment Provider”). You must provide SECRET GALLERY with valid account information for the respective chosen Payment Provider. Your Payment Provider agreement governs your use of the designated credit card or other payment method, and you must refer to that agreement and not the Terms to determine your rights and liabilities. By providing SECRET GALLERY with your payment information, you agree that SECRET GALLERY is authorized to immediately invoice your Account for all fees and charges due and payable to SECRET GALLERY hereunder and that no additional notice or consent is required. You agree to immediately notify SECRET GALLERY of any change in payment credentials for payment hereunder. SECRET GALLERY reserves the right at any time to change its prices and billing methods, either immediately upon posting on the Website or by e-mail delivery to you.

        6.3 Service Subscription Fees.

        You will be responsible for payment of the applicable fee for any Services (each, a “Service Subscription Fee”) at the time you create your Account and select the term of your subscription (each, a “Service Commencement Dat”). Except as set forth in the Terms, all fees for the Services are non-refundable. No contract will exist between you and SECRET GALLERY for the Services until SECRET GALLERY or the Payment Provider, for example Apple or Google, accepts your order by a confirmatory e-mail, SMS/MMS message, or other appropriate means of communication.

        6.4 Taxes.

        SECRET GALLERY’s fees are net of any applicable Sales Tax. If any Service, or payments for any Service, are subject to Sales Tax in any jurisdiction and you have not remitted the applicable Sales Tax to SECRET GALLERY, you will be responsible for the payment of such Sales Tax and any related penalties or interest to the relevant tax authority and you will indemnify SECRET GALLERY for any liability or expense we may incur in connection with such Sales Taxes. Upon our request, you will provide us with official receipts issued by the appropriate taxing authority, or such other evidence that you have paid all applicable taxes. For purposes of this section, “Sales Tax” shall mean any sales or use tax, and any other tax measured by sales proceeds, that SECRET GALLERY its permitted to pass to its customers that is the functional equivalent of a sales tax where the applicable taxing jurisdiction does not otherwise impose a sales or use tax.

        6.5 Automatic Renewal.

        Your subscription will continue indefinitely until terminated in accordance with the Terms. After your initial subscription period, and again after any subsequent subscription period, your subscription will automatically commence on the first day following the end of such period (each a “Renewal Commencement Date”) and continue for an additional equivalent period, at SECRET GALLERY’s then-current price for such subscription. You agree that your Account will be subject to this automatic renewal feature unless you cancel your subscription at least 24 hours prior to the Renewal Commencement Date by logging into and going to the “Manage App Subscriptions” page in the Apple App Store or the “My Apps” page in the Google Play Store app. The same page will permit you to change your Account settings if you do not wish your subscription to renew automatically, or if you want to change or terminate your subscription.If you cancel your subscription, you may use your subscription until the end of your then-current subscription term; your subscription will not be renewed after your then-current term expires. However, you will not be eligible for a prorated refund of any portion of the subscription fee paid for the then- current subscription period. By subscribing, you authorize SECRET GALLERY to charge your Payment Provider now, and again at the beginning of any subsequent subscription period. Upon renewal of your subscription, if SECRET GALLERY does not receive payment from your Payment Provider, (i) you agree to pay all amounts due on your Account upon demand, and/or (ii) you agree that SECRET GALLERY may either terminate or suspend your subscription and continue to attempt to charge your Payment Provider until payment is received (upon receipt of payment, your Account will be re-activated and for purposes of automatic renewal, your new subscription commitment period will begin as of the day payment was received).

        6.6 Pre-purchased Minutes and Texts.

        Users of the Telephony Service may be able to purchase calling minutes and text messaging packages (collectively, “Pre-Purchased Packages“). Pre-Purchased Packages are not legal tender and cannot be reloaded, resold, transferred for value, redeemed for cash or applied to any other account, except to the extent described herein or as required by applicable law. SECRET GALLERY prohibits and does not recognize any purported transfers of Pre-Purchased Packages outside of the Telephony Services, or the purported sale, lease, gift or trade in the “real world” of anything that appears or originates outside of the Telephony Services. Accordingly, you may not trade, sell or attempt to sell Pre-Purchased Packages for “real” money, or exchange those items or currency for value of any kind outside the Telephony Services. Any such transfer or attempted transfer is prohibited and void, and will subject your Account to termination. You shall ensure that you have sufficient Pre-Purchased Packages in your Account before you initiate any transaction that requires such credits. If you have insufficient Telephony Credits in your Account to complete the transaction, the transaction will be cancelled. ALL TRANSACTIONS MADE USING Pre-Purchased Packages ARE FINAL AND ARE NON-REFUNDABLE.

        SECRET GALLERY Is Provided As-Is.
        SECRET GALLERY CANNOT GUARANTEE THAT YOUR CONTENT WILL BE SAFE FROM OUTSIDE ATTACKS, HACKERS OR OTHER WAYS OF ACCESSING YOUR CONTENT ON THE FILE SYSTEMS. YOU EXPRESSLY UNDERSTAND AND AGREE THAT TO THE EXTENT PERMITTED BY APPLICABLE LAW, YOUR USE OF THE SECRET GALLERY PROPERTIES IS AT YOUR SOLE RISK, AND THE SECRET GALLERY PROPERTIES ARE PROVIDED ON AN “AS IS” AND “AS AVAILABLE” BASIS, WITH ALL FAULTS. SECRET GALLERY EXPRESSLY DISCLAIMS ALL WARRANTIES, REPRESENTATIONS, AND CONDITIONS OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

        Limitation of Liability.
        YOU UNDERSTAND AND AGREE THAT IN NO EVENT SHALL SECRET GALLERY BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES ARISING OUT OF OR IN CONNECTION WITH THE WEBSITE, THE APPLICATION, THE SOFTWARE, THE SERVICE, INCLUDING WITHOUT LIMITATION, ANY DAMAGES RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR NOT SECRET GALLERY HAD BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. UNDER NO CIRCUMSTANCES WILL SECRET GALLERY BE LIABLE TO YOU FOR MORE THAN THE AMOUNT RECEIVED BY SECRET GALLERY AS A RESULT OF YOUR USE OF THE SERVICE DURING THE TWELVE-MONTH PERIOD PRECEDING THE DATE ON WHICH YOU FIRST ASSERT YOU CLAIM. IF YOU HAVE NOT PAID SECRET GALLERY ANY AMOUNTS DURING SUCH PERIOD, SECRET GALLERY’S SOLE AND EXCLUSIVE LIABILITY SHALL BE LIMITED TO FIFTY DOLLARS ($50.00).

        THE TELEPHONY SERVICES ARE NOT INTENDED TO SUPPORT OR CARRY EMERGENCY CALLS OR SMS MESSAGES TO ANY EMERGENCY SERVICES. NEITHER SECRET GALLERY NOR ITS SUPPLIERS WILL BE LIABLE UNDER ANY LEGAL OR EQUITABLE THEORY FOR ANY CLAIM, DAMAGE OR LOSS ARISING FROM OR RELATED TO THE INABILITY TO USE THE TELEPHONY SERVICES TO CONTACT EMERGENCY SERVICES.

        Remedies
        9.1 Violations.

        If SECRET GALLERY becomes aware of any possible violations by you of the Terms, SECRET GALLERY reserves the right to investigate such violations. If, as a result of the investigation, SECRET GALLERY believes that criminal activity has occurred, SECRET GALLERY reserves the right to refer the matter to, and to cooperate with, any and all applicable legal authorities. SECRET GALLERY is entitled, except to the extent prohibited by applicable law, to disclose any information or materials on the SECRET GALLERY Properties, including Your Content, in SECRET GALLERY’s possession in connection with your use of the SECRET GALLERY Properties, to (1) comply with applicable laws, legal process or governmental request; (2) enforce the Terms; (3) respond to any claims that Your Content violates the rights of third parties; (4) respond to your requests for customer service; or (5) protect the rights, property or personal safety of SECRET GALLERY, its Users or the public, and all enforcement or other government officials, as SECRET GALLERY in its sole discretion believes to be necessary or appropriate.

        9.2 Breach.

        In the event that SECRET GALLERY determines, in its sole discretion, that you have breached any portion of the Terms, or have otherwise demonstrated inappropriate conduct, SECRET GALLERY reserves the right to:

        (a) Warn you via e-mail (to any e-mail address you have provided to SECRET GALLERY) that you have violated the Terms;

        (b) Delete any of Your Content provided by you or your agent(s) to the SECRET GALLERY Properties;

        (c) Discontinue your registration(s) with the SECRET GALLERY Properties;

        (d) Discontinue your subscription to any Service;

        (e) Notify and/or send Your Content to and/or fully cooperate with the proper law enforcement authorities for further action; and/or

        (f) Pursue any other action which SECRET GALLERY deems to be appropriate.

        9.3 No Subsequent Registration.

        If your registration(s) with or ability to access the SECRET GALLERY Properties is discontinued by SECRET GALLERY due to your violation of any portion of the Terms, then you agree that you shall not attempt to re-register with or access the SECRET GALLERY Properties through use of a different member name or otherwise, and you acknowledge that you will not be entitled to receive a refund for fees related to those SECRET GALLERY Properties to which your access has been terminated. In the event that you violate the immediately preceding sentence, SECRET GALLERY reserves the right, in its sole discretion, to immediately take any or all of the actions set forth herein without any notice or warning to you.

        Miscellaneous Legal Terms.
        10.1 Electronic Communications

        The communications between you and SECRET GALLERY use electronic means, whether you visit the Website or send SECRET GALLERY e-mails, or whether SECRET GALLERY posts notices on the Website or communicates with you via e-mail. For contractual purposes, you (1) agree to receive communications from SECRET GALLERY in an electronic form; and (2) agree that all terms and conditions, agreements, notices, disclosures, and other communications that SECRET GALLERY provides to you electronically satisfy any legal requirement that such communications would satisfy if it were to be in writing. The foregoing does not affect your statutory rights.

        10.2 Release

        You hereby release SECRET GALLERY and its successors from claims, demands, any and all losses, damages, rights, and actions of any kind, including personal injuries, death, and property damage of any kind arising in connection with or as a result of the Terms or your use of the Website, the Application, the Software or the Service. If you are a California resident, you hereby waive California Civil Code Section 1542, which states, “A general release does not extend to claims which the creditor does not know or suspect to exist in his favor at the time of executing the release, which, if known by him must have materially affected his settlement with the debtor.

        10.3 Assignment

        The Terms, and your rights and obligations hereunder, may not be assigned, subcontracted, delegated, or otherwise transferred by you without SECRET GALLERY’s prior written consent, and any attempted assignment, subcontract, delegation, or transfer in violation of the foregoing will be null and void.

        10.4 Force Majeure

        SECRET GALLERY and its licensors shall not be liable for any delay or failure to perform resulting from causes outside its reasonable control, including, but not limited to, acts of God; war; terrorism; riots; embargos; acts of civil or military authorities; fire; floods; accidents; strikes or shortages of transportation facilities; fuel; energy; labor; materials; problems with your computing or network infrastructure, hardware or product; problems with your internet service provider (ISP) or any sites you are attempting access through the VPN Service; or any electrical or other utility outage.

        10.5 Dispute Resolution

        (a) Any claim or dispute (excluding claims for injunctive or other equitable relief as set forth below) in connection with the Terms where the total amount of the award sought is less than Five Thousand U.S. Dollars (US $5,000.00) may be resolved in a cost effective manner through binding non-appearance-based arbitration, at the option of the party seeking relief. Such arbitration shall be initiated through an established alternative dispute resolution provider (“ADR Provider”) that offers arbitration as set forth in this section and under the rules of such ADR Provider, except to the extent such rules are in conflict with the Terms. The party demanding arbitration will propose an ADR Provider and the other party shall not unreasonably withhold consent to use such ADR Provider. The ADR Provider and the parties must comply with the following rules: (1) the arbitration shall be conducted by telephone, online and/or be solely based on written submissions, the specific manner shall be chosen by the party initiating the arbitration; (2) all arbitration proceedings shall be held in English; (3) the arbitration shall not involve any personal appearance by the parties or witnesses unless otherwise mutually agreed to by the parties; and (4) any judgment on the award rendered by the arbitrator may be entered in any court of competent jurisdiction. Each party shall bear its own costs (including attorney fees) and disbursements arising out of the arbitration, and shall pay an equal share of the fees and costs of the ADR Provider. Notwithstanding the foregoing, SECRET GALLERY may seek injunctive or other equitable relief to protect its intellectual property rights in any court of competent jurisdiction. Please note that the laws of the jurisdiction where you are located may be different from California law, including the laws governing what can legally be sold, bought, exported, offered or imported. You shall always comply with all the international and domestic laws, ordinances, regulations and statutes that are applicable to your use of the SECRET GALLERY Properties.
        (b) Any other dispute (including whether the claims asserted are arbitrable) shall be referred to and finally determined by binding and confidential arbitration. Arbitration shall be subject to the Federal Arbitration Act and not any state arbitration law. The arbitration shall be conducted before one commercial arbitrator with substantial experience in resolving commercial contract disputes from the American Arbitration Association (“AAA”). As modified by the Terms, and unless otherwise agreed upon by the parties in writing, the arbitration will be governed by the AAA’s Commercial Arbitration Rules and, if the arbitrator deems them applicable, the Supplementary Procedures for Consumer Related Disputes (collectively “Rules and Procedures”).
        (c) You are thus GIVING UP YOUR RIGHT TO GO TO COURT to assert or defend your rights EXCEPT for matters that may be taken to small claims court. Your rights will be determined by a NEUTRAL ARBITRATOR and NOT a judge or jury. You are entitled to a FAIR HEARING, BUT the arbitration procedures are SIMPLER AND MORE LIMITED THAN RULES APPLICABLE IN COURT. Arbitrator decisions are as enforceable as any court order and are subject to VERY LIMITED REVIEW BY A COURT.
        (d) You and SECRET GALLERY must abide by the following rules: (i) ANY CLAIMS BROUGHT BY YOU OR SECRET GALLERY MUST BE BROUGHT IN THE PARTIES’ INDIVIDUAL CAPACITY, AND NOT AS A PLAINTIFF OR CLASS MEMBER IN ANY PURPORTED CLASS OR REPRESENTATIVE PROCEEDING; (ii) THE ARBITRATOR MAY NOT CONSOLIDATE MORE THAN ONE PERSON’S CLAIMS, MAY NOT OTHERWISE PRESIDE OVER ANY FORM OF A REPRESENTATIVE OR CLASS PROCEEDING, AND MAY NOT AWARD CLASS-WIDE RELIEF; (iii) in the event that you are able to demonstrate that the costs of arbitration will be prohibitive as compared to costs of litigation, SECRET GALLERY will pay as much of your filing and hearing fees in connection with the arbitration as the arbitrator deems necessary to prevent the arbitration from being cost-prohibitive as compared to the cost of litigation; (iv) SECRET GALLERY also reserves the right in its sole and exclusive discretion to assume responsibility for all of the costs of the arbitration; (v) the arbitrator shall honor claims of privilege and privacy recognized at law; (vi) the arbitration shall be confidential, and neither you nor we may disclose the existence, content or results of any arbitration, except as may be required by law or for the purposes of enforcement of the arbitration award; (vii) the arbitrator may award any individual relief or individual remedies that are permitted by applicable law; and (viii) each side pays its own attorneys’ fees and expenses unless there is a statutory provision that requires the prevailing party to be paid its fees and litigation expenses, and then in such instance, the fees and costs awarded shall be determined by applicable law.
        (e) The arbitral proceedings, and all pleadings and written evidence will be in the English language. Any written evidence originally in a language other than English will be submitted in English translation accompanied by the original or true copy thereof. The English language version will control. The arbitrator shall issue a written award and statement of decision describing the essential findings and conclusions on which the award is based, including the calculation of any damages awarded. The arbitrator will not have authority to award damages in excess of the amount, or other than the types, allowed by Section 8 of the Terms. Judgment on the award of the arbitrator may be entered by any court of competent jurisdiction. The arbitrator also shall be authorized to grant any temporary, preliminary or permanent equitable remedy or relief it deems just and equitable and within the scope of the Terms, including, without limitation, an injunction or order for specific performance. The arbitration award shall be final and binding upon the parties without appeal or review except as permitted by California law or United States federal law.Notwithstanding the foregoing, either you or SECRET GALLERY may bring an individual action in small claims court. Further, claims of defamation, violation of the Computer Fraud and Abuse Act, and infringement or misappropriation of the other party’s patent, copyright, trademark, or trade secret shall not be subject to this arbitration agreement. Such claims shall be exclusively brought in the state or federal courts located in San Francisco County, California. Additionally, notwithstanding this agreement to arbitrate, either party may seek emergency equitable relief before the state or federal courts located in San Francisco County, California, in order to maintain the status quo pending arbitration, and hereby agree to submit to the exclusive personal jurisdiction of the courts located within San Francisco County, California for such purpose. A request for interim measures shall not be deemed a waiver of the right to arbitrate.
        (f) With the exception of (d)(i) and (ii) above (prohibiting arbitration on a class or collective basis), if any part of this arbitration provision is deemed to be invalid, unenforceable, or illegal, or otherwise conflicts with the Rules and Procedures, then the balance of this arbitration provision shall remain in effect and shall be construed in accordance with its terms as if the invalid, unenforceable, illegal or conflicting provision were not contained herein. If, however, either (d)(i) or (ii) is found to be invalid, unenforceable or illegal, then the entirety of this arbitration provision shall be null and void, and neither you nor SECRET GALLERY shall be entitled to arbitration. If for any reason, a claim proceeds in court rather than in arbitration, the dispute shall be exclusively brought in state or federal court in San Francisco County, California. By using the SECRET GALLERY Properties in any manner, you agree to the above arbitration provision.
        For more information on AAA, its Rules and Procedures, and how to file an arbitration claim, you may call AAA at 800-778-7879 or visit the AAA website at http://www.adr.org.

        10.6 Choice of Law and Venue.

        The Terms and any action related thereto will be governed and interpreted by and under the laws of the State of California, without giving effect to any conflict of laws principles that require the application of the law of a different state. You hereby expressly agree to the personal jurisdiction and venue in the state and federal courts for the county in which SECRET GALLERY’s principal place of business is located for any lawsuit filed against you by SECRET GALLERY arising from or related to the Terms.

        10.7 Notice.

        Where SECRET GALLERY requires that you provide an e-mail address, you are responsible for providing SECRET GALLERY with your most current e-mail address. In the event that the last e-mail address you provided to SECRET GALLERY is not valid, or for any reason is not capable of delivering to you any notices required/permitted by the Terms, SECRET GALLERY’s dispatch of the e-mail containing such notice will nonetheless constitute effective notice. You may give notice to SECRET GALLERY at the following address: 427 Bryant St., San Francisco, CA 94107. Such notice shall be deemed given when received by SECRET GALLERY by letter delivered by nationally recognized overnight delivery service or first class postage prepaid mail at the above address.

        10.8 Waiver.

        Any waiver or failure to enforce any provision of the Terms on one occasion will not be deemed a waiver of any other provision or of such provision on any other occasion.

        10.9 Severability.

        If any provision of the Terms is, for any reason, held to be invalid or unenforceable, the other provisions of the Terms will remain enforceable, and the invalid or unenforceable provision will be deemed modified so that it is valid and enforceable to the maximum extent permitted by law.

        10.10 App Stores.

        Youacknowledgeandagreethattheavailabilityofthe Application and the Services is dependent on the third party from whom you received the Application license, e.g., the Apple iPhone or Android app stores (“App Store”). You acknowledge and agree that the Terms are between you and SECRET GALLERY only, and not with the App Store. SECRET GALLERY, not the App Store, is solely responsible for the SECRET GALLERY Properties, including the Application, the contents thereof, maintenance, support services, and warranty therefor, and addressing any claims relating thereto (e.g., product liability, legal compliance or intellectual property infringement). In order to use the Application, you must have access to a wireless network, and you agree to pay all fees associated with such access. You also agree to pay all fees (if any) charged by the App Store in connection with the SECRET GALLERY Properties, including the Application. You agree to comply with, and your license to use the Application is conditioned upon your compliance with, all applicable third- party terms of agreement (e.g., the App Store’s terms and policies) when using the SECRET GALLERY Properties, including the Application. You acknowledge that the App Store (and its subsidiaries) are third-party beneficiaries of the Terms and will have the right to enforce them.

        10.11 Accessing and Download the Application from iTunes.

        The following applies to any App Store Sourced Application accessed through or downloaded from the Apple App Store:

        (a) You acknowledge and agree that (i) the Terms are concluded between you and SECRET GALLERY only, and not Apple, and (ii) SECRET GALLERY, not Apple, is solely responsible for the App Store Sourced Application and content thereof. Your use of the App Store Sourced Application must comply with the App Store Terms of Service.

        (b) You acknowledge that Apple has no obligation whatsoever to furnish any maintenance and support services with respect to the App Store Sourced Application.

        (c) In the event of any failure of the App Store Sourced Application to conform to any applicable warranty, you may notify Apple, and Apple will refund the purchase price for the App Store Sourced Application to you and to the maximum extent permitted by applicable law, Apple will have no other warranty obligation whatsoever with respect to the App Store Sourced Application. As between SECRET GALLERY and Apple, any other claims, losses, liabilities, damages, costs or expenses attributable to any failure to conform to any warranty will be the sole responsibility of SECRET GALLERY.

        (d) You and SECRET GALLERY acknowledge that, as between SECRET GALLERY and Apple, Apple is not responsible for addressing any claims you have or any claims of any third party relating to the App Store Sourced Application or your possession and use of the App Store Sourced Application, including, but not limited to: (i) product liability claims; (ii) any claim that the App Store Sourced Application fails to conform to any applicable legal or regulatory requirement; and (iii) claims arising under consumer protection or similar legislation.

        (e) You and SECRET GALLERY acknowledge that, in the event of any third party claim that the App Store Sourced Application or your possession and use of that App Store Sourced Application infringes that third party’s intellectual property rights, as between SECRET GALLERY and Apple, SECRET GALLERY, not Apple, will be solely responsible for the investigation, defense, settlement and discharge of any such intellectual property infringement claim to the extent required by the Terms.

        (f) You and SECRET GALLERY acknowledge and agree that Apple, and Apple’s subsidiaries, are third party beneficiaries of the Terms as related to your license of the App Store Sourced Application, and that, upon your acceptance of the terms and conditions of the Terms, Apple will have the right (and will be deemed to have accepted the right) to enforce the Terms as related to your license of the App Store Sourced Application against you as a third party beneficiary thereof.

        (g) Without limiting any other terms of the Terms, you must comply with all applicable third party terms of agreement when using the App Store Sourced Application.

        10.12 Export Control.

        You may not use, export, import, or transfer the SECRET GALLERY Properties except as authorized by U.S. law, the laws of the jurisdiction in which you obtained the SECRET GALLERY Properties, and any other applicable laws. In particular, but without limitation, the SECRET GALLERY Properties may not be exported or re-exported (a) into any United States embargoed countries, or (b) to anyone on the U.S. Treasury Department’s list of Specially Designated Nationals or the U.S. Department of Commerce’s Denied Person’s List or Entity List. By using the SECRET GALLERY Properties, you represent and warrant that (i) you are not located in a country that is subject to a U.S. Government embargo, or that has been designated by the U.S. Government as a “terrorist supporting” country and (ii) you are not listed on any U.S. Government list of prohibited or restricted parties. You also will not use the SECRET GALLERY Properties for any purpose prohibited by U.S. law, including the development, design, manufacture or production of missiles, nuclear, chemical or biological weapons. You acknowledge and agree that products, services or technology provided by SECRET GALLERY are subject to the export control laws and regulations of the United States. You shall comply with these laws and regulations and shall not, without prior U.S. government authorization, export, re-export, or transfer the SECRET GALLERY products, services or technology, either directly or indirectly, to any country in violation of such laws and regulations..

        10.13 International Users.

        The SECRET GALLERY Properties can be accessed from countries around the world and may contain references to Services and Content that are not available in your country. These references do not imply that SECRET GALLERY intends to announce such Services or Content in your country. The SECRET GALLERY Properties are controlled and offered by SECRET GALLERY from its facilities in the United States of America. SECRET GALLERY makes no representations that SECRET GALLERY Properties are appropriate or available for use in other locations. Those who access or use the SECRET GALLERY Properties from other jurisdictions do so at their own volition and are responsible for compliance with local law.

        10.14 Questions, Complaints, and Claims.

        If you have any questions, complaints or claims, please contact us at: support@getSECRET GALLERY.com. We will do our best to address your concerns. If you feel that your concerns have been addressed incompletely, we invite you to let us know for further investigation.

        10.15 Consumer Complaints.

        In accordance with California Civil Code §1789.3, you may report complaints to the Complaint Assistance Unit of the Division of Consumer Service of the California Department of Consumer Affairs by contacting them in writing at 400 R Street, Sacramento, CA 95814, or by telephone at (800) 952-5210.

        10.16 Entire Agreement.

        The Terms are the final, complete and exclusive agreement of the parties with respect to the subject matter hereof and supersedes and merges all prior discussions between the parties with respect to such subject matter.

        International Provisions.
        The following provisions shall apply only if you are located in the countries listed below.

        11.1 United Kingdom.

        A third party who is not a party to the Terms has no right under the Contracts (Rights of Third Parties) Act 1999 to enforce any provision of the Terms, but this does not affect any right or remedy of such third party which exists or is available apart from that Act.

        11.2 Germany.

        Notwithstanding anything to the contrary in Section 8, SECRET GALLERY is also not liable for acts of simple negligence (unless they cause injuries to or death of any person), except when they are caused by a breach of any substantial contractual obligations (vertragswesentliche Pflichten).
        """
        
        bodyLabel.numberOfLines = 0
        bodyLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        contentView.addSubview(bodyLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        // ScrollView
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        // ContentView
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(view)
        }
        
        // Texto
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-20)
        }
    }
}
