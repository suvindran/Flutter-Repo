import { Component, OnInit } from '@angular/core';
import { NavbarService } from '../../navbar.service';

@Component({
  selector: 'main-footer',
  templateUrl: './main-footer.component.html',
  styleUrls: ['./main-footer.component.css']
})
export class MainFooterComponent implements OnInit {

  constructor(public nav: NavbarService) { }

  ngOnInit() {
  }

}
