import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {NgbModule} from '@ng-bootstrap/ng-bootstrap';
import { QueueComponent } from './queue/queue.component';
import { HomePageComponent } from './home-page/home-page.component';
import { AngularFontAwesomeModule } from 'angular-font-awesome';
import { MainNavComponent } from './main-nav/main-nav.component';
import { MainFooterComponent } from './main-footer/main-footer.component';

@NgModule({
  imports: [
    CommonModule,
    AngularFontAwesomeModule,
    RouterModule,
    NgbModule,    
  ],
  declarations: [
    QueueComponent,     
    MainNavComponent,
    HomePageComponent,
    MainFooterComponent,
  ],
  exports: [
    QueueComponent,     
    MainNavComponent,
    HomePageComponent,
    MainFooterComponent,
  ]
})
export class UiModule { }
