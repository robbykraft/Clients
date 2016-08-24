//
//  MoreViewController.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class MercyViewController: UIViewController {

	let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "WORKS OF MERCY AND THE SIX PILLARS"
		
		self.view.addSubview(textView)
		
		textView.textContainerInset = UIEdgeInsetsMake(20, 8, 0, 8)
		textView.font = UIFont(name: SYSTEM_FONT, size: 15)
		textView.text = "“Small gestures of love, of tenderness, of care, make people feel that the Lord is with us. This is how the door of mercy opens.” – Pope Francis on Twitter, March 2016\nAs we continue in this Jubilee Year of Mercy, Pope Francis reminds us of the profound need to bring God’s love and mercy to our world. We are reminded to “be merciful just as your Father [God] is merciful” (Lk 6:36) and are encouraged to practice the Spiritual and Corporal Works of Mercy. These “Works of Mercy” connect very naturally with the Six Pillars of Character. In fact, it can be argued that if we are looking for concrete ways to live out Trustworthiness, Respect, Responsibility, Fairness, Caring, and Citizenship, we have a built in road map in the Spiritual and Corporal Works of Mercy.\n\nSpiritual Works of Mercy:\nCounsel the doubtful\nInstruct the ignorant\nAdmonish the sinner\nComfort the sorrowful\nForgive offenses\nBear wrongs patiently\nPray for the living and dead\n\nCorporal Works of Mercy:\nFeed the hungry\nGive drink to the thirsty\nClothe the naked\nShelter the homeless\nVisit the sick\nComfort the imprisoned\nBury the dead\n\nThe following is a short list of ways the Works of Mercy and Six Pillars can be woven together:\n\nPlan a service learning project (food collection, clothing drive, nursing home visit, etc.) that embodies the words “CARING” – “RESPECT” – “RESPONSIBILITY”; help students recognize the intentional connection their efforts have with one or more of these Pillars.\nHave students prepare a “Spiritual Bouquet” (i.e., a promise of prayers to be said for someone in need, whether that person is sick, homebound, grieving, etc.); make the intentional connection that prayer is placing one’s “TRUST” in God and can be a powerful way of cultivating “TRUSTWORTHINESS” and hope for someone in need.\nOffer a critical thinking writing assignment on how each of the Spiritual Works of Mercy can provide an opportunity to practice true FAIRNESS or justice towards one’s neighbor (i.e., a service of humility rather than pride; a way of helping another person “grow” rather than “breaking her down.” For example, when one “instructs the ignorant” or “admonishes the sinner,” he or she can do so with a sense of genuine fairness/justice (helping another person to grow in faith and character).\nAsk students to examine current events (from newspaper, online articles, magazines, TV news, social media) and identify people who are being exemplary CITIZENS by practicing one or more of the Corporal Works of Mercy. Alternatively, ask students to identify an ethical crisis from current events and explain how people might be good citizens and resolve the crisis with specific Corporal Works of Mercy.\nAssign students (or have them “pick out of a hat”) a Spiritual or Corporal Work of Mercy and do a small public speaking presentation on how that Work of Mercy connects with one or more of the Six Pillars. For example, if a student was assigned “Forgiving offenses,” he/she might explain how this Spiritual Work of Mercy exemplifies the pillars of CARING, RESPECT, and/or RESPONSIBILITY."
		
//		let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
//		                  NSKernAttributeName : CGFloat(2.4),
//		                  NSForegroundColorAttributeName : UIColor.whiteColor()];
//		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "MY CHARACTER SCORE")
//		aTitle1.addAttributes(attributes, range: NSMakeRange(0, aTitle1.length))
//		button1.setAttributedTitle(aTitle1, forState: .Normal)

	}
	
	override func viewWillAppear(animated: Bool) {
		let PAD = CGFloat(0)//self.view.frame.size.width * 0.1
		textView.frame = CGRectMake(PAD, 0, self.view.frame.size.width - PAD * 2, self.view.frame.size.height)
	}
}
