import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { NavbarService } from './../../navbar.service';

@Component({
  selector: 'main-nav',
  templateUrl: './main-nav.component.html',
  styleUrls: ['./main-nav.component.css']
})
export class MainNavComponent implements OnInit {

  constructor(public router: Router,
    public nav: NavbarService) { }

  ngOnInit() {
  }
}
