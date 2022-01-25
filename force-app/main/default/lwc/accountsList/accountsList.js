import { LightningElement, api, track, wire } from 'lwc';
import getAccountsByName from '@salesforce/apex/AccountHelper.getAccountsByName';
import getAccountFields from '@salesforce/apex/AccountHelper.getAccountFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountsList extends LightningElement {

    @api resultSize;
    @api columns = ''
    @track data = []
    @track tableColumns = []

    connectedCallback() {
        this.getAccountFieldsJS();
    }

    getAccountFieldsJS() {
        getAccountFields({fields: JSON.stringify(this.columns.split(','))})
        .then(resp => {
            this.tableColumns = [...resp];
        }).catch(err => {
            console.log(err);
            this.showToast('[Cols] Error', 'Error: '+err.body.message, 'error');
        });
    }
    getAccountsByNameJS(evt) {
        getAccountsByName({ name: evt.target.value})
        .then(resp => {
            this.data = resp;
        }).catch(err => {
            console.log(err);
            this.showToast('[Rows] Error', 'Error: '+err.body.message, 'error');
        });
    }

    showToast( title, msg, variation) {
        this.dispatchEvent( new ShowToastEvent({
            title: title,
            message: msg,
            variation: variation
        }));
    }
}