import { Component, OnInit } from '@angular/core';
import { NavbarService } from './../../navbar.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-home-page',
  templateUrl: './home-page.component.html',
  styleUrls: ['./home-page.component.css']
})
export class HomePageComponent implements OnInit {

  constructor(public nav: NavbarService,
    public router: Router) { }

  ngOnInit() {
    this.nav.show();
  }

}
