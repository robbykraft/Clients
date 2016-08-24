//
//  MoreViewController.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LiturgicalViewController: UIViewController {

	let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "Faith and Character"
		
		self.view.addSubview(textView)
	
		textView.textContainerInset = UIEdgeInsetsMake(20, 8, 0, 8)
		textView.font = UIFont(name: SYSTEM_FONT, size: 15)
		textView.text = "Faith and Character: Integrating the Six Pillars with the Liturgical Calendar\n\nCharacter Counts’ Six Pillars – Trustworthiness, Respect, Responsibility, Fairness, Caring, and Citizenship – can be readily integrated with the liturgical calendar of the Catholic Church. With Advent (the beginning of the new liturgical year) upon us, the timing is right!\n\nLiturgy comes from the Greek word leitourgeios which translates as “service”, as in serving God through public and communal worship. One of the helpful ways to think about the liturgical year therefore is the public and communal worship of God over the course of a one year period. Just as families celebrate birthdays, special events, holidays, and seasons, so too does the universal Church (aka – “the Family of God”) celebrate Jesus’ birthday, special holy days, saints’ feast days and the rhythm of the seasons. Through rituals and routines; color, signs and sacred places; language and gestures; sound and song; times and seasons; the cycles of nature; and – above all – sacraments, scripture, and prayer, the Church’s liturgical calendar celebrates the mystery of salvation in Jesus Christ and – through the working of the Holy Spirit – provides a means to encounter Jesus as we journey from day to day.\n\nThe Six Pillars of Character are something that we must work at on a daily basis and the liturgical calendar can help us with this. When we immerse ourselves in the liturgical life of the Church and strive to live these pillars, one can begin to glimpse at an authentic Christian witness. As Pope Francis has said, “the Church is calling us to have and to promote an authentic liturgical life, so that there may be harmony between what the liturgy celebrates, and what we live in our daily existence.” The liturgy, the pope continues, “is the privileged place to hear the voice of the Lord, who guides us on the path to righteousness and Christian perfection” (Pope Francis, Homily – July 2015).\n\nThe following is a short list of ways the Six Pillars can be integrated with the liturgical calendar:\n- Make connections between the Six Pillars and the Six Seasons of the liturgical calendar – possible connections include: Advent (trustworthiness), Christmas Time (caring), Lent (responsibility), Sacred Paschal Triduum (“profound” respect), Easter Time (fulfillment of “true” fairness), and Ordinary Time (Christ-centered citizenship)\n- Saints Feast Days offer a time to highlight the lives of many different people who embodied one or more of the Six Pillars with heroic fidelity\n- Readings from Mass – highlight the Pillars in the readings from daily Mass and especially Sunday Mass (see http://www.usccb.org/bible/readings/112915.cfm) \n- Reverence, as practiced in liturgical prayer, can be connected with the Pillar of genuine Respect for the greatness, beauty and love of God\n- Growing in virtue and the Six Pillars can be an on-going prayer intention – one that is woven throughout our day-to-day and weekly school prayers, as well as incorporated in school liturgies\n- Devotion to Mary and celebrating Mary’s feast days offers countless opportunities to meditate upon a life of tremendous character and a true example of the Six Pillars “offered up” for the love of Jesus Christ\n- Throughout this liturgical year – one Pope Francis has declared the Jubilee Year of Mercy --follow the homilies/writings of the holy father and identify the centrality of the Six Pillars and the ongoing themes of love and forgiveness (see http://www.im.va/content/gdm/en.html)"
		
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
