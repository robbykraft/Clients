//
//  MoreViewController.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class MotherViewController: UIViewController {

	let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "OUR BLESSED MOTHER MARY"
		
		self.view.addSubview(textView)

		textView.textContainerInset = UIEdgeInsetsMake(20, 8, 0, 8)
		textView.font = UIFont(name: SYSTEM_FONT, size: 15)
		textView.text = "In the Catholic Faith, Mary plays a huge role. Mary is the woman who was especially \"Blessed\" and chosen by God to be the Mother of our Lord, Jesus Christ. When the angel Gabriel appeared to Mary and told her that she would be the mother of Jesus, Mary responded, \"Behold, I am the handmaid of the Lord. Let it be done unto me according to your word.\" In other words, she said \"YES\" to the great responsibility of being the Mother of God. Mary and her husband Joseph raised Jesus in a home filled with simplicity and love. When Jesus was dying on the cross (with Mary weeping at the foot of the cross), He communicated to his disciple John (who was also at the foot of the cross) that Mary was to be the Mother of the Church. In Jesus' own words, He said to John, \"Behold your mother.\" One of the great modern saints, Mother Theresa of Calcutta, explained that Jesus -- being a faithful Son to Mary -- would have certainly obeyed the Fourth Commandment (\"Honor your father and mother.\") and therefore when we turn to Mary, Our Blessed Mother, we are simply imitating Jesus Christ Himself.How did Mary display TRUSTWORTHINESS?\nShe trusted in the will of God; she had great faith; she lived the message -- \"Thy will be done\" -- that we pray in the Our Father, meaning that she trusted in God's will (what He wanted rather than what she wanted).\n\nHow did Mary display RESPECT?\n - Outside of Jesus, Mary is the greatest example of respect. She had tremendous respect for God and lived a life of absolute purity. She obeyed all of God's commandments and always kept her priorities straight -- first things first, she respected God and everything \"flowed\" from this proper and most respectful way of ordering her life.\nHow did Mary display RESPONSIBILITY?\n - Although she was just a teenager and not highly educated (through formal schooling), Mary took on the greatest responsibility in the history of the world - that is, being the Mother of Jesus Christ, the Savior of the world. She could have run from this responsibility, but instead she accepted it and remained loyal to it her entire life. Just a few moments that we are familiar with and that demonstrate Mary's responsibility: protecting Jesus when he was in her womb; ensuring that he was \"wrapped in swaddling clothes\" (warm and cozy!) in the manger; going in search of Him when, as a young boy, he disappeared and was later found by Mary and Joseph in the temple; helping the bride and groom at the Wedding Feast at Cana (getting Jesus to help them with his first public miracle of producing more wine when the guests had run out of it); being with Jesus (\"accompanying Him!\") along the Way of the Cross (each station); and finally remaining with Jesus in his final moments on the cross. Again, she never ran from her HUGE Responsibilities!\n\n\nHow did Mary display FAIRNESS?\n - True fairness or justice is giving to God what is owed to God, and giving to our neighbors what is owed to them. Mary was completely \"fair\" her entire life. She never cheated God and she never cheated another person. In fact, her fairness extended to immense generosity. She didn't hold anything back for herself, but rather gave abundantly.\nHow did Mary display CARING?\n - Mary was completely caring. She was always looking out for others. This was true in how she treated her son, Jesus; her husband, Joseph; and everyone else. We don't know about all of the countless details of her daily life, but we do know that Mary -- being so pure and holy -- would have poured her heart into all of these details. She, more than anyone else, understood that everything that a person does in his or her life is an opportunity to please God and to show Him how much we love Him. Mary sanctified or made \"holy\" everything she did. Mary's example teaches us that ordinary, day-to-day life offers countless opportunities to show how much we care for God and others.\nHow did Mary display CITIZENSHIP?\n - A good citizen not only obeys the law, but also contributes in a positive way to society. Simply put, he or she tries to make the world a better place. Once again, no one was a better citizen than Mary. Her entire life was one of obedience and sacrifice for the good of others. An interesting point to think about: What if Mary did not obey God when he asked her to be the Mother of the Savior of the world? Of course, this is hard to imagine -- but if Mary had done her own will (rather than God's will), Jesus might have never entered our world; countries like the United States might not have known Jesus and His teachings, and maybe countries like the US might not even exist. Again, it is almost impossible to imagine a world without Jesus Christ, but yet that's what might have happened without Mary \"doing her part\".\n\nSome practical ways we can follow Our Blessed Mother's example and live out the Six Pillars of Character:\n\n- Ask Mary to pray for us and help us to grow in the Six Pillars and be like her! (She will take our prayers right to Jesus' heart, and since He is such a good Son, He will listen to his Mother.)\n- Like Jesus and Mary, we can make an effort to be very trustworthy and honest with our parents, our families (including our brothers and sisters), our teachers, our friends, and everyone we know. If we say we're going to do something, we should keep our word. Also, if we break a promise or let someone down, we should apologize.\n- Watch and listen to good and pure things; avoid feeding our brains with \"garbage\" (negative or inappropriate shows and videos on the computer or television)\n- Treat everyone with respect and dignity -- even people whom we may not \"like\". Make a little list of kind things you can say or do to treat other people more respectfully.\n- Keep a little picture of Mary next to our bed or somewhere where we'll see it often and be reminded of her.\n- Really focus on the words of prayers to Mary and meditate (think deeply about) what they mean and how we can imitate her virtue.\n- Carry with us, and pray with, Rosary beads. The Rosary offers us a calming, peaceful, and most importantly powerful way to turn to Mary, meditate on the life of Jesus Christ, and bring our intentions to God (including the intention of growing in virtue and being more like Mary - genuinely Trustworthy, Respectful, Responsible, Caring, and a good Citizen).\n- Do the ordinary \"little things\" of each day (school work, little chores, conversations, playing with friends, eating meals, homework, etc.) with a truly caring heart.\n- Prepare a \"spiritual bouquet\" (a thoughtful card or note with a promise of certain prayers for someone) as a way of reaching out to them and showing that, like Our Lady, we deeply respect and care for them."
		
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
