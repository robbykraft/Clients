//
//  EmailMaker.swift
//  Voila
//
//  Created by Robby on 8/23/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class EmailMaker {
	
	static let shared = EmailMaker()
	
	fileprivate init() {
	}
	
	var htmlHeader = "<!DOCTYPE html><html><body style=\"background-color: #EEE; padding:2em;\"><div style=\"background-color: #FFF; padding:2em;\">"
	var htmlFooter = "</div></body></html>"
	
	var headerText = "Home Staging • Re-Styling • Interior Design • Developer Services • Painting"
	
	var summaryText = "Voila Design is Philadelphia’s award winning Home Staging and Interior Design firm. Awarded the \"Best of Philly\" accolade for Home Staging as well as a 26 episode Interior Design agreement with HGTV, the Voila Design team has proven themselves to be an industry leader in the Tri- State Area and beyond. The Voila Design team specializes in preparing properties to sell for the highest market value and in the shortest amount of time. Unlike the competition, Voila Design owns top of the line furnishings, accessories and artwork which allows every Home Staging project to be customized to suit each and every space. The award winning Voila Design team has the unique ability to turn a space from bland to grand in 24 hours or less!"
	
	var contractText = "<h4>a) Definitions:</h4><p>Home Staging - Terms and Conditions<br>Base Contract: includes delivery of home staging services such as designer time, furniture moving in and out of property, transportation cost, rental of furniture and accessories for the preset period of time, typically three months. It is billed as one-time charge upon delivery.<br>Renewal Fee: includes rental of furniture and accessories for following periods upon Base Contract expiration. It is billed on a monthly base.</p><h4>b) Payment terms</h4><p>Upon accepting this proposal an advance payment of 50% of Base Contract price is due in order to secure a slot on our schedule. Balance payment is due 7 days before staging services are delivered and before any additional changes are made, if requested.<br>Base Contract fee shall not be prorated if the home sells prior to the end of the contract.</p><h4>c) Sales Tax</h4><p>Sales Tax is applied to home staging services.</p><h4>d) Payments methods</h4><p>Credit Cards and QuickBooks \"Pay Now\" feature: <strong>A processing fee of 2% of the transaction value is added to the total charge</strong>.<br>Checks: can be mailed to <strong>Voila Design Home Services LLC, 1630 S Broad St, Philadelphia PA 19145</strong></p><h4>e) When the property sells</h4><p>If the staged property goes under contract and passes most contingencies during the Base Contract time period, 7 days’ notice must be given in order to secure a pull date for removal of furniture out of the property. In case the removal’s request is received with less than 7 days’ notice a \"Rush Removal Fee\" of $250 will be automatically charged to Client.<br>If the property sells but Voila Design Home Services does not receive any notification or request for removal of furniture the Base Contract will continue and renewal fees will be eventually due.<br>If the staged property sells 48 hours before scheduled staging, Client may be charged 15% of staging costs for restocking.</p><h4>f) Renewals Terms</h4><p>When a Base Contract expires the Renewal Fee is due on monthly basis unless a request for furniture removal is sent to Voila Design Home Services within 7 days from Base Contract expiration date or any following renewal expiration date.<br>Unless other form of payment is provided, Renewal fees are automatically charged to Client’s credit card the first day of the renewal period.<br>Voila Design Home Services reserves the right to remove furniture from staged property in case of failure in monthly Renewal Fee payment.</p><h4>g) Disclaimer</h4><p>Client acknowledges that this staging contract is independent by any other real estate sales contract, agreement or arrangements between the Client and any other party such as, but not limited to: Buyer, Seller, developer, other contractors or real estate agencies involved in the listing, sale or purchase transactions.</p><h4>h) Client’s responsibilities</h4><p>Client agrees to allow access to the staged property to Voila Design Home Services employees during regular business hours (Monday to Friday 8.00am to 5.00 pm).<br>Client agrees to provide lock box and alarm codes for staged property as well as to keep keys in the lock box at all times during the length of this contract. Clients shall notify Voila Design Home Services when codes change.<br>Client is liable to take good care of the staged property, to maintain furniture in safe condition and to return all items to Voila Design Home Services in the condition received.<br>Client agrees to refund Voila Design Home Staging for any missing or damaged furniture item or accessories, including items missing or damaged as result of theft, vandalism, flood or fire at the property staged.<br>Client acknowledges that furnishings and accessories are owned by Voila Design Home Services and are intended for display purposes only. If there is evidence of habitation during the rental period, a cleaning/repair fee will be charged to client of at least $500.<br>Client acknowledges and agrees that all furnishings shall remain at the staged property during the entire term of this agreement and shall not be removed from the property, except by Voila Design Home Services’ staff.<br>Client is responsible to pay any third party fee such as move in/out fee, elevator fee, as required to deliver or remove the stage furniture.<br>All added personal items must be removed from the property prior to the final removal from the Voila Design Home Team. If personal items are added to the stage, Voila Design Home is not responsible if items are missing after the staging furniture and accessories are removed.<br>Client is responsible to ensure that the property is finished and ready for staging. This includes the interior unit, and corridors and stairwells leading to the unit, exterior of the building, outlining premises, and street to the building. If Voila Design Home Services’ team arrives to the property and is unable to deliver, client will be charged a $350 fee each time.<br>Voila Design Home Services is aware of the bedbug risks; we take extra measures to be pro-active in preventing an infestation. If an infestation should occur during the rental period, Voila Design Home Services will not be held liable for the damages. Furthermore, infestation will be considered a total loss and client is responsible for replacing the full value of the staging furniture.</p><h4>i) Our Commitment</h4><p>Voila Design Home Services’ team has the knowledge and proper experience to understand the aesthetics of any room. This is validated by the rate at which homes are sold as a result of Voila Design Home Services’estaging.<br>If Client is unhappy with the condition (damaged or dirty) pieces that are selected for the space, we will re-evaluate one time if necessary at no cost. A fee will apply for any additional re-evaluation.</p>"

}
