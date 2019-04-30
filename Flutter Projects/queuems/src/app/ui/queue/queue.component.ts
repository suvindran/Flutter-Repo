import { Component, OnInit } from '@angular/core';
import { AngularFirestore, AngularFirestoreCollection } from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import {
  trigger,
  state,
  style,
  animate,
  transition,
  keyframes
} from '@angular/animations';
import { NavbarService } from '../../navbar.service';
import { ActivatedRoute } from '@angular/router';


@Component({
  selector: 'app-queue',
  templateUrl: './queue.component.html',
  styleUrls: ['./queue.component.css'],
  animations: [
    trigger('flyInOut', [
      state('in', style({transform: 'translateX(0)'})),
      transition('void => *', [
        animate(1000, keyframes([
          style({opacity: 0, transform: 'translateX(-100%)', offset: 0}),
          style({opacity: 1, transform: 'translateX(15px)',  offset: 0.3}),
          style({opacity: 1, transform: 'translateX(0)',     offset: 1.0})
        ]))
      ]),
      transition('* => void', [
        animate(1000, keyframes([
          style({opacity: 1, transform: 'translateX(0)',     offset: 0}),
          style({opacity: 1, transform: 'translateX(-15px)', offset: 0.7}),
          style({opacity: 0, transform: 'translateX(100%)',  offset: 1.0})
        ]))
      ])
    ])
  ]
})
export class QueueComponent implements OnInit {

  items: Observable<any[]>;
  onQueueItems: Observable<any[]>;
  emptyItems = [];
  itemSound: any;
  companyKey: string;
  subRoute: any;

  constructor(public db: AngularFirestore, public nav: NavbarService, public route: ActivatedRoute) {
    
  }

  ngOnInit() {
    this.nav.hide();
    this.subRoute = this.route.params.subscribe(params => {
      this.companyKey = params['companyKey']; 
    });

    var now = new Date();
    this.items = this.db.collection('tokenIssued', ref => 
      ref.where('reset', '==', false)
      .where('companyKey', '==', this.companyKey)
      .orderBy('assignedDate', 'desc').limit(4)
    ).valueChanges();
    
    this.onQueueItems = this.db.collection('tokenIssued', ref => 
      ref.where('isOnQueue', '==', true)
      .where('reset', '==', false)
      .where('companyKey', '==', this.companyKey)
      .orderBy('assignedDate', 'desc').limit(1)
    ).valueChanges();

    this.items.subscribe(data=> {
      this.emptyItems = [];
      for (var i=data.length; i<4; i++){
        this.emptyItems.push("");
      }
    });  
  }

  ngOnDestroy() {
    this.subRoute.unsubscribe();
  }
}
