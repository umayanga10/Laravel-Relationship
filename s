<?php

namespace App\Http\Controllers\Web\Organization;

use App\Http\Controllers\Controller;
use App\Models\Organization\SalesDivision;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SalesDivisionController extends Controller
{
    
    public function index(){
        return view('contents.organization.division.index');
    }

    public function save(Request $request){
        DB::beginTransaction();
        try {

            for ($i = 1; $i <= $request->item_count; $i++) {
                if(isset($request['sales_division_name_' . $i])){
                    $sales_division = SalesDivision::create([
                        'sd_code'=>$request['sales_division_code_' . $i],
                        'sd_name'=>$request['sales_division_name_' . $i]
                    ]);
                }
            }
            DB::commit();
            return redirect()->route('sales_division')->with('success', 'RECORD HAS BEEN SUCCESSFULLY INSERTED!');
        } catch (\Exception $e) {
            DB::rollback();
            return redirect()->route('sales_division')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY INSERTED!');
        }
    }

    public function view() {
        $sales_division = SalesDivision::withTrashed()->get();
        return view('contents.organization.division.view',compact('sales_division'));
    }

    public function edit(Request $request) {
        $sales_division = SalesDivision::find($request->id);
        return view('contents.organization.division.edit',compact('sales_division'));
    }

    public function update(Request $request,$id) {
        $sales_division = SalesDivision::find($id);
        $sales_division->sd_code = $request->get('sales_division_code_1');
        $sales_division->sd_name = $request->get('sales_division_name_1');
        $sales_division->save();
        if($sales_division){
            return redirect()->route('sales_division_view')->with('success', 'RECORD HAS BEEN SUCCESSFULLY UPDATED!');
        } else {
            return redirect()->route('sales_division_view')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY UPDATED!');
        }
    }

    public function change_status(Request $request) {
        if($request->status == 0){
            SalesDivision::withTrashed()->find($request->id)->restore();
            session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY RESTORED!');
        } elseif($request->status == 1){
            SalesDivision::find($request->id)->delete();
            session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY DELETED!');
        }
    }

}
// index

@extends('layouts.app')
@section('css')

@endsection

@section('title', config('sfa.type'))

@section('content')
<div class="container-fluid dashboard-content ">
    <!-- ============================================================== -->
    <!-- pageheader  -->
    <!-- ============================================================== -->
    <div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <div class="page-header" style="text-align: center;">
                <h2 class="pageheader-title">ADD SALES DIVISION</h2>
                <div class="page-breadcrumb">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                           
                        </ol>
                    </nav>
                </div>
            </div>
        </div>
    </div>
    <!-- ============================================================== -->
    <!-- end pageheader  -->
    <!-- ============================================================== -->
    <div class="ecommerce-widget">
        <form action="{{url('sales_division/save')}}" method="post" name="sales_division_form" id="sales_division_form" onsubmit="sales_division_validation();"> 
        @csrf
        <div class="row">
            <div class="col-md-3 col-sm-12 col-xs-12 form-group">
            </div>
            <div class="col-md-6 col-sm-12 col-xs-12 form-group text-center">
                <table class="table table-striped table-bordered first">
                    <thead class="thead-custom">
                        <tr>
                            <th style="text-align: center">&nbsp</th>
                            <th style="text-align: center">SALES DIVISION CODE</th>
                            <th style="text-align: center">SALES DIVISION NAME</th>
                            <th style="text-align: center">&nbsp</th>
                        </tr>
                    </thead>
                    <tbody id="sales_division">
                        <tr id="tr_1">
                            <td style="text-align: center">
                                <span class="color-success" style="cursor: pointer; font-size:18px" onclick="gen_item();">
                                    <i class="bi bi-plus-square-fill"></i>
                                </span>
                            </td>
                            <td>
                            <input type="text" id="sales_division_code_1" name="sales_division_code_1" class="col-md-12 form-control form-control-sm" autocomplete="off" />
                            </td>
                            <td>
                            <input type="text" id="sales_division_name_1" name="sales_division_name_1" class="col-md-12 form-control form-control-sm" autocomplete="off" />
                            </td>
                            <td style="text-align: center">
                                <span class="color-danger" style="cursor: pointer; font-size:18px" onclick="remove_item('1');">
                                    <i class="bi bi-x-square-fill"></i>
                                </span>
                            </td>
                        </tr>
                    </tbody>
                    <input type="hidden" id="item_count" name="item_count" value="1" />
                    <input type="hidden" id="delete_item_count" name="delete_item_count" value="1" />
                </table>
                <div class="form-group mt-sm-1 mb-sm-1">
                    <div class="">
                        <button class="btn btn-secondary btn-sm" type="button" onclick="reset_page()">CLEAR</button>
                        <button type="button" id="add" class="btn btn-primary btn-sm" onclick="form_submit('add', 'sales_division_form')">SAVE</button>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-12 col-xs-12 form-group">
            </div>
        </div>
        </form>
    </div>
</div>
@endsection

@section('js')
<script type="text/javascript">
    /* GENERATE NEW ROW */
    function gen_item(){
        var num = parseFloat($('#item_count').val()) + 1;
        $('#item_count').val(num);
        var delete_count = parseFloat($('#delete_item_count').val()) + 1;
        $('#delete_item_count').val(delete_count);
        $('#sales_division').append('<tr class="even pointer" id="tr_' + num + '">'
                + '<td style="text-align: center">'
                    + '<span class="color-success" style="cursor: pointer; font-size:18px" onclick="gen_item();">'
                    +     '<i class="bi bi-plus-square-fill"></i>'
                    + '</span>'
                + '</td>'
                + '<td>'
                    +'<input type="text" id="sales_division_code_' + num + '" name="sales_division_code_' + num + '" class="col-md-12 form-control form-control-sm" autocomplete="off" />'
                + '</td>'
                + '<td>'
                    +'<input type="text" id="sales_division_name_' + num + '" name="sales_division_name_' + num + '" class="col-md-12 form-control form-control-sm" autocomplete="off" />'
                + '</td>'
                + '<td style="text-align: center">'
                    + '<span class="color-danger" style="cursor: pointer; font-size:18px" onclick="remove_item('+ num +');">'
                    +    '<i class="bi bi-x-square-fill"></i>'
                    + '</span>'
                + '</td>'
                + '</tr>');
        $('#sales_division_code_'+num).focus();
    }

    /*REMOVE GENERATED ROW*/
    function remove_item(num) {
        $('#tr_' + num).remove();
        var num = parseFloat($('#delete_item_count').val()) - 1;
        $('#delete_item_count').val(num);
        if (num == 0) {
            gen_item();
        }
    }

    function reset_page(){
        $.confirm({
        title: 'Confirm?',
            content: 'Are you sure do you want to reset ?',
            type: 'green',
            buttons: {
                Okey: {
                    text: 'Yes',
                    btnClass: 'btn-blue',
                    action: function () {
                        location.reload();
                    }
                },
                cancel: {
                    text: 'No',
                    btnClass: 'btn-red',
                    action: function () {
                    
                    }
                }
            }
        });
    }

    function sales_division_validation(){
        valid = true;
        for (m = 1; m <= parseInt($('#item_count').val()); m++) {
            if ($('#sales_division_code_' + m).val() == "") {
                valid = false;
                $('#sales_division_code_' + m).focus();
                $.alert({
                    title: 'Alert',
                    icon: 'fa fa-warning',
                    type: 'green',
                    content: 'Enter Sales Division Code'
                });
                break;
            } else if ($('#sales_division_name_' + m).val() == "") {
                valid = false;
                $('#sales_division_name_' + m).focus();
                $.alert({
                    title: 'Alert',
                    icon: 'fa fa-warning',
                    type: 'green',
                    content: 'Enter Sales Division Name'
                });
                break;
            }
        }
        return valid;
    }

    function form_submit(button_id, form_id) {
        if (sales_division_validation()) {
            $.confirm({
            title: 'Confirm?',
                content: 'Are you sure do you want submit this record',
                type: 'green',
                buttons: {
                    Okey: {
                        text: 'confirm',
                        btnClass: 'btn-blue',
                        action: function () {
                            document.getElementById(button_id).style.display = "none";
                            document.forms[form_id].submit();
                        }
                    },
                    cancel: {
                        text: 'cancel',
                        btnClass: 'btn-red',
                        action: function () {

                        }
                    }
                }
            });
        }
    }
</script>
@endsection


//view

@extends('layouts.app')

@section('css')
    @include('includes.datatables.css')
@endsection

@section('title', config('sfa.type'))

@section('content')
<div class="container-fluid dashboard-content ">
    <!-- ============================================================== -->
    <!-- pageheader  -->
    <!-- ============================================================== -->
    <div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <div class="page-header" style="text-align: center;">
                <h2 class="pageheader-title">VIEW SALES DIVISION</h2>
                <div class="page-breadcrumb">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">

                        </ol>
                    </nav>
                </div>
            </div>
        </div>
    </div>
    <!-- ============================================================== -->
    <!-- end pageheader  -->
    <!-- ============================================================== -->
    @php
    use App\Models\User\User;
    if(isset(Auth::user()->u_tp_id)) {
        $checkUserPermitedUrledit = User::checkUserPermitedUrl('SALES DIVISION EDIT');
        $checkUserPermitedUrldelete = User::checkUserPermitedUrl('SALES DIVISION DELETE');
    }
    @endphp
    <div class="ecommerce-widget">
        <div class="row">
            <div class="col-md-2 col-sm-12 col-xs-12 form-group">
            </div>
            <div class="col-md-8 col-sm-12 col-xs-12 form-group text-center">
                <div class="card">
                    <div class="card-body">
                        <table class="table table-striped table-bordered first">
                            <thead class="thead-custom">
                                <tr>
                                    <th style="text-align: center">&nbsp</th>
                                    <th style="text-align: center">SALES DIVISION CODE</th>
                                    <th style="text-align: center">SALES DIVISION NAME</th>
                                    <th style="text-align: center">ADDED DATE</th>
                                    <th style="text-align: center">EDIT</th>
                                    <th style="text-align: center">STATUS</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($sales_division as $key=>$sd)
                                @php $key = $key+1; @endphp
                                <tr>
                                    <td>{{$key}}</td>
                                    <td style="text-align: left">{{$sd->sd_code}}</td>
                                    <td style="text-align: left">{{$sd->sd_name}}</td>
                                    <td>{{$sd->created_at}}</td>
                                    <td>
                                        @if(!$sd->trashed())
                                        <div style="text-align:center">
                                            @if ($checkUserPermitedUrledit)
                                            <a href="{{url('sales_division/edit', $sd->sd_id)}}" target="_blank"><i
                                                    style="color:#0998b0;font-size:18px"
                                                    class="fas fa-pencil-alt fa-lg"></i></a>
                                            @else
                                            <a href="javascript:void(0);"><i style="color:gray;font-size:18px"
                                                    class="fas fa-pencil-alt fa-lg"></i></a>
                                            @endif
                                        </div>
                                        @endif
                                    </td>
                                    <td>
                                        @if (!$sd->trashed())
                                        @php $current_status = 1; @endphp

                                        <div style="text-align:center">
                                            @if ($checkUserPermitedUrldelete)
                                            <a href="" onclick="change_status('{{$current_status}}','{{$sd->sd_id}}')"
                                                class="btn btn-success btn-sm">Enable</a>
                                            @else
                                            <button disabled="disabled" class="btn btn-success btn-sm">Enable</button>
                                            @endif

                                        </div>
                                        @else
                                        @php $current_status = 0; @endphp
                                        <div style="text-align:center">
                                            @if ($checkUserPermitedUrldelete)
                                            <a href="" onclick="change_status('{{$current_status}}','{{$sd->sd_id}}')"
                                                class="btn btn-danger btn-sm">Disable</a>
                                            @else
                                            <button disabled="disabled" class="btn btn-danger btn-sm">Disable</button>
                                            @endif
                                        </div>
                                        @endif
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-12 col-xs-12 form-group">
            </div>
        </div>
    </div>
</div>
@endsection
@section('js')

@include('includes.datatables.js')

<script type="text/javascript">

    function change_status(status,id){
        event.preventDefault();
        $.confirm({
        title: 'Confirm?',
            content: 'Are you sure do you want change status of this record',
            type: 'green',
            buttons: {
                Okey: {
                    text: 'confirm',
                    btnClass: 'btn-blue',
                    action: function () {
                        $.ajax({
                            type: "POST",
                            url: "{{ url('/sales_division/status') }}",
                            data: {
                                id: id,
                                status: status,
                                "_token": "{{ csrf_token() }}"
                            },
                            success: function (data) {
                                window.location.href = "{{ route('sales_division_view')}}";
                            }
                        });
                    }
                },
                cancel: {
                    text: 'cancel',
                    btnClass: 'btn-red',
                    action: function () {

                    }
                }
            }
        });
    }

</script>
@endsection

//edit
@extends('layouts.app')

@section('title', config('sfa.type'))

@section('content')
<div class="container-fluid dashboard-content ">
    <!-- ============================================================== -->
    <!-- pageheader  -->
    <!-- ============================================================== -->
    <div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <div class="page-header" style="text-align: center;">
                <h2 class="pageheader-title">EDIT SALES DIVISION</h2>
                <div class="page-breadcrumb">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                           
                        </ol>
                    </nav>
                </div>
            </div>
        </div>
    </div>
    <!-- ============================================================== -->
    <!-- end pageheader  -->
    <!-- ============================================================== -->
    <div class="ecommerce-widget">
        <form action="{{url('sales_division/update',$sales_division->sd_id)}}" method="post" name="sales_division_edit_form" id="sales_division_edit_form" onsubmit="sales_division_edit_validation();"> 
        @csrf
        <div class="row">
            <div class="col-md-3 col-sm-12 col-xs-12 form-group">
            </div>
            <div class="col-md-6 col-sm-12 col-xs-12 form-group text-center">
                <table class="table table-striped table-bordered first">
                    <thead class="thead-custom">
                        <tr>
                            <th style="text-align: center">SALES DIVISION CODE</th>
                            <th style="text-align: center">SALES DIVISION NAME</th>
                        </tr>
                    </thead>
                    <tbody id="zone">
                        <tr id="tr_1">
                            <td>
                            <input type="text" id="sales_division_code_1" name="sales_division_code_1" value="{{$sales_division->sd_code}}" class="col-md-12 form-control form-control-sm" autocomplete="off" />
                            </td>
                            <td>
                            <input type="text" id="sales_division_name_1" name="sales_division_name_1" value="{{$sales_division->sd_name}}" class="col-md-12 form-control form-control-sm" autocomplete="off" />
                            </td>
                        </tr>
                    </tbody>
                    <input type="hidden" id="item_count" name="item_count" value="1" />
                    <input type="hidden" id="delete_item_count" name="delete_item_count" value="1" />
                </table>
                <div class="form-group mt-sm-1 mb-sm-1">
                    <div class="">
                        <button class="btn btn-secondary btn-sm" type="button" onclick="reset_page()">CLEAR</button>
                        <button type="button" id="add" class="btn btn-primary btn-sm" onclick="form_submit('add', 'sales_division_edit_form')">UPDATE</button>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-12 col-xs-12 form-group">
            </div>
        </div>
        </form>
    </div>
</div>
@endsection
@section('js')

<script type="text/javascript">

    function reset_page(){
        $.confirm({
        title: 'Confirm?',
            content: 'Are you sure do you want to reset ?',
            type: 'green',
            buttons: {
                Okey: {
                    text: 'Yes',
                    btnClass: 'btn-blue',
                    action: function () {
                        location.reload();
                    }
                },
                cancel: {
                    text: 'No',
                    btnClass: 'btn-red',
                    action: function () {
                    
                    }
                }
            }
        });
    }

    function sales_division_edit_validation(){
        valid = true;
        for (m = 1; m <= parseInt($('#item_count').val()); m++) {
            if ($('#sales_division_code_' + m).val() == "") {
                valid = false;
                $('#sales_division_code_' + m).focus();
                $.alert({
                    title: 'Alert',
                    icon: 'fa fa-warning',
                    type: 'green',
                    content: 'Enter Sales Division Code'
                });
                break;
            } else if ($('#sales_division_name_' + m).val() == "") {
                valid = false;
                $('#sales_division_name_' + m).focus();
                $.alert({
                    title: 'Alert',
                    icon: 'fa fa-warning',
                    type: 'green',
                    content: 'Enter Sales Division Name'
                });
                break;
            }
        }
        return valid;
    }

    function form_submit(button_id, form_id) {
        if (sales_division_edit_validation()) {
            $.confirm({
            title: 'Confirm?',
                content: 'Are you sure do you want submit this record',
                type: 'green',
                buttons: {
                    Okey: {
                        text: 'confirm',
                        btnClass: 'btn-blue',
                        action: function () {
                            document.getElementById(button_id).style.display = "none";
                            document.forms[form_id].submit();
                        }
                    },
                    cancel: {
                        text: 'cancel',
                        btnClass: 'btn-red',
                        action: function () {

                        }
                    }
                }
            });
        }
    }

</script>
@endsection





<?php

use App\Http\Controllers\API\Sales\V1\UnproductiveController;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\Web\CommonFunctionController;
use App\Http\Controllers\Web\Competitor\CompetitorController;
use App\Http\Controllers\Web\Gps\GpsMapController;
use App\Http\Controllers\Web\Itinerary\DayTypeController;
use App\Http\Controllers\Web\Itinerary\ItineraryController;
use App\Http\Controllers\Web\Itinerary\MonthTemplateController;
use App\Http\Controllers\Web\Order\InvoiceController;
use App\Http\Controllers\Web\Order\SalesOrderController;
use App\Http\Controllers\Web\Organization\AreaController;
use App\Http\Controllers\Web\Organization\CustomerCategoryController;
use App\Http\Controllers\Web\Organization\CustomerClassController;
use App\Http\Controllers\Web\Organization\CustomerController;
use App\Http\Controllers\Web\Organization\RegionController;
use App\Http\Controllers\Web\Organization\RouteController;
use App\Http\Controllers\Web\Organization\SalesDivisionController;
use App\Http\Controllers\Web\Organization\ZoneController;
use App\Http\Controllers\Web\Other\ApkUploadController;
use App\Http\Controllers\Web\Other\BankController;
use App\Http\Controllers\Web\Other\ExpenseController;
use App\Http\Controllers\Web\Other\PaymentTypeController;
use App\Http\Controllers\Web\Other\SystemComponentController;
use App\Http\Controllers\Web\Other\SystemReasonsController;
use App\Http\Controllers\Web\Other\UnplanedVisitController;
use App\Http\Controllers\Web\Other\VatController;
use App\Http\Controllers\Web\Product\ProductGiftItemController;
use App\Http\Controllers\Web\Product\ProductMainCategoryController;
use App\Http\Controllers\Web\Product\ProductMasterController;
use App\Http\Controllers\Web\Product\ProductPosmController;
use App\Http\Controllers\Web\Product\ProductSkuController;
use App\Http\Controllers\Web\Product\ProductSubCategoryController;
use App\Http\Controllers\Web\Promotion\AdhocFreeIssueController;
use App\Http\Controllers\Web\Promotion\AssortedFreeIssueController;
use App\Http\Controllers\Web\Promotion\DiscountController;
use App\Http\Controllers\Web\Promotion\DiscountFlatContoller;
use App\Http\Controllers\Web\Promotion\DiscountCustomerController;
use App\Http\Controllers\Web\Promotion\FreeIssueHierarchyController;
use App\Http\Controllers\Web\Promotion\LineFreeIssueController;
use App\Http\Controllers\Web\Promotion\PromotionPriorityController;
use App\Http\Controllers\Web\Promotion\ValueFreeIssueController;
use App\Http\Controllers\Web\Stock\OpenStockController;
use App\Http\Controllers\Web\Stock\PurchaseOrderController;
use App\Http\Controllers\Web\Test\ImportController;
use App\Http\Controllers\Web\User\UserController;
use App\Http\Controllers\Web\User\UserTypeController;
use App\Http\Controllers\Web\Other\MessageController;
use App\Http\Controllers\Web\Report\RepAttendanceController;
use App\Http\Controllers\Web\Report\SalesRepController;
use App\Http\Controllers\Web\Report\ItemController;
use App\Http\Controllers\Web\Report\ShopReportController;
use App\Http\Controllers\Web\Report\AreaWiseShopController;
use App\Http\Controllers\Web\Report\RouteWiseShopController;
use App\Http\Controllers\Web\Distributor\DistributorController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', [LoginController::class, 'index'])->name('index');
Route::post('/authenticate', [LoginController::class, 'authenticate'])->name('authenticate');
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

Route::group(['middleware' => ['auth']], function () { 

    Route::get('home', [LoginController::class, 'home'])->name('home');

    // Sales division
    Route::group(['prefix' => 'sales_division'], function () {
        Route::get('load', [SalesDivisionController::class, 'index'])->name('sales_division');
        Route::post('save', [SalesDivisionController::class, 'save']);
        Route::get('view', [SalesDivisionController::class, 'view'])->name('sales_division_view');
        Route::get('edit/{id}', [SalesDivisionController::class, 'edit']);
        Route::post('update/{id}', [SalesDivisionController::class, 'update']);
        Route::post('status', [SalesDivisionController::class, 'change_status']);
    });

    // Zone 
    Route::group(['prefix' => 'zone'], function () {
        Route::get('load', [ZoneController::class, 'index'])->name('zone_registration');
        Route::post('get_sales_division', [ZoneController::class, 'get_sales_division']);
        Route::post('save', [ZoneController::class, 'save']);
        Route::get('view', [ZoneController::class, 'view'])->name('zone_view');
        Route::get('search', [ZoneController::class, 'search']);
        Route::get('edit/{id}', [ZoneController::class, 'edit']);
        Route::post('update/{id}', [ZoneController::class, 'update']);
        Route::post('status', [ZoneController::class, 'change_status']);
    });

    // Region
    Route::group(['prefix' => 'region'], function () {
        Route::get('load', [RegionController::class, 'index'])->name('region_registration');
        Route::post('get_zone', [RegionController::class, 'get_zone']);
        Route::post('save', [RegionController::class, 'save']);
        Route::get('view', [RegionController::class, 'view'])->name('region_view');
        Route::get('search', [RegionController::class, 'search']);
        Route::get('edit/{id}', [RegionController::class, 'edit']);
        Route::post('update/{id}', [RegionController::class, 'update']);
        Route::post('status', [RegionController::class, 'change_status']);
        Route::get('transfer', [RegionController::class, 'transfer'])->name('region_transfer');
        Route::get('transfer/search', [RegionController::class, 'transfer_search']);
        Route::post('transfer/save', [RegionController::class, 'transfer_save']);
    });

    // Area (In view use as Territory)
    Route::group(['prefix' => 'area'], function () {
        Route::get('load', [AreaController::class, 'index'])->name('area_registration');
        Route::post('get_zone', [AreaController::class, 'get_zone']);
        Route::post('get_region', [AreaController::class, 'get_region']);
        Route::post('save', [AreaController::class, 'save']);
        Route::get('view', [AreaController::class, 'view'])->name('area_view');
        Route::get('search', [AreaController::class, 'search']);
        Route::get('edit/{id}', [AreaController::class, 'edit']);
        Route::post('update/{id}', [AreaController::class, 'update']);
        Route::post('status', [AreaController::class, 'change_status']);
        Route::get('transfer', [AreaController::class, 'transfer'])->name('area_transfer');
        Route::get('transfer/search', [AreaController::class, 'transfer_search']);
        Route::post('transfer/save', [AreaController::class, 'transfer_save']);
    });

    // Route
    Route::group(['prefix' => 'route'], function () {
        Route::get('load', [RouteController::class, 'index'])->name('route_registration');
        Route::post('get_zone', [RouteController::class, 'get_zone']);
        Route::post('get_region', [RouteController::class, 'get_region']);
        Route::post('get_area', [RouteController::class, 'get_area']);
        Route::post('save', [RouteController::class, 'save']);
        Route::get('view', [RouteController::class, 'view'])->name('route_view');
        Route::get('search', [RouteController::class, 'search']);
        Route::get('edit/{id}', [RouteController::class, 'edit']);
        Route::post('update/{id}', [RouteController::class, 'update']);
        Route::post('status', [RouteController::class, 'change_status']);
        Route::get('transfer', [RouteController::class, 'transfer'])->name('route_transfer');
        Route::get('transfer/search', [RouteController::class, 'transfer_search']);
        Route::post('transfer/save', [RouteController::class, 'transfer_save']);
    });

    // Customer Category (In view use as Outlet Category)
    Route::group(['prefix' => 'customer_category'], function () {
        Route::get('load', [CustomerCategoryController::class, 'index'])->name('customer_category');
        Route::post('save', [CustomerCategoryController::class, 'save']);
        Route::get('view', [CustomerCategoryController::class, 'view'])->name('customer_category_view');
        Route::get('edit/{id}', [CustomerCategoryController::class, 'edit']);
        Route::post('update/{id}', [CustomerCategoryController::class, 'update']);
        Route::post('status', [CustomerCategoryController::class, 'change_status']);
    });

    // Customer Class (In view use as Outlet Class)
    Route::group(['prefix' => 'customer_class'], function () {
        Route::get('load', [CustomerClassController::class, 'index'])->name('customer_class');
        Route::post('save', [CustomerClassController::class, 'save']);
        Route::get('view', [CustomerClassController::class, 'view'])->name('customer_class_view');
        Route::get('edit/{id}', [CustomerClassController::class, 'edit']);
        Route::post('update/{id}', [CustomerClassController::class, 'update']);
        Route::post('status', [CustomerClassController::class, 'change_status']);
    });

    // Customer (In view use as Outlet)
    Route::group(['prefix' => 'customer'], function () {
        Route::get('load', [CustomerController::class, 'index'])->name('customer');
        Route::post('save', [CustomerController::class, 'save']);
        Route::get('view', [CustomerController::class, 'view'])->name('customer_view');
        Route::get('search', [CustomerController::class, 'search']);
        Route::get('edit/{id}', [CustomerController::class, 'edit']);
        Route::post('update/{id}', [CustomerController::class, 'update']);
        Route::post('delete', [CustomerController::class, 'distroy']);
        Route::get('export', [CustomerController::class, 'export']);
        Route::get('transfer', [CustomerController::class, 'transfer'])->name('customer_transfer');
        Route::get('transfer/search', [CustomerController::class, 'transfer_search']);
        Route::post('transfer/save', [CustomerController::class, 'transfer_save']);
    });

    // User Type 
    Route::group(['prefix' => 'user_type'], function () {
        Route::get('load', [UserTypeController::class, 'index'])->name('user_type');
        Route::post('save', [UserTypeController::class, 'save']);
        Route::get('view', [UserTypeController::class, 'view'])->name('user_type_view');
        Route::get('edit/{id}', [UserTypeController::class, 'edit']);
        Route::post('update/{id}', [UserTypeController::class, 'update']);
        Route::post('status', [UserTypeController::class, 'change_status']);
    });

    // User
    Route::group(['prefix' => 'user'], function () {
        Route::get('load', [UserController::class, 'index'])->name('user_registration');
        Route::post('check_ucode', [UserController::class, 'check_ucode']);
        Route::post('check_discode', [UserController::class, 'check_discode']);
        Route::post('distributor', [UserController::class, 'distributor']);
        Route::post('area', [UserController::class, 'area']);
        Route::post('save', [UserController::class, 'save']);
        Route::get('view', [UserController::class, 'view'])->name('user_view');
        Route::get('search', [UserController::class, 'search']);
        Route::get('edit/{id}', [UserController::class, 'edit'])->name('user_edit');
        Route::post('update/{id}', [UserController::class, 'update']);
        Route::post('status', [UserController::class, 'change_status']);
    });

    // Day Types
    Route::group(['prefix' => 'day_type'], function () {
        Route::get('load', [DayTypeController::class, 'index']);
        Route::post('save', [DayTypeController::class, 'save']);
        Route::get('view', [DayTypeController::class, 'view'])->name('day_type');
        Route::get('search', [DayTypeController::class, 'search']);
        Route::get('status', [DayTypeController::class, 'change_status']);
        Route::get('edit/{id}', [DayTypeController::class, 'edit']);
        Route::post('update/{id}', [DayTypeController::class, 'update']);
    });

    // Month Template
    Route::group(['prefix' => 'month_template'], function () {
        Route::get('load', [MonthTemplateController::class, 'index'])->name('month_template');
        Route::post('load_details', [MonthTemplateController::class, 'load_details']);
        Route::post('save', [MonthTemplateController::class, 'save']);
        Route::get('view', [MonthTemplateController::class, 'view'])->name('month_template_view');
        Route::get('search', [MonthTemplateController::class, 'search']);
        Route::get('display/{id}', [MonthTemplateController::class, 'display']);
        Route::get('edit/{id}', [MonthTemplateController::class, 'edit'])->name('month_template_edit');
        Route::post('update/{id}', [MonthTemplateController::class, 'update']);
    });

    // Itinerary
    Route::group(['prefix' => 'itinerary'], function () {
        Route::get('load', [ItineraryController::class, 'index'])->name('itinerary_registration');
        Route::get('sales_rep', [ItineraryController::class, 'sales_rep']);
        Route::post('load_info', [ItineraryController::class, 'load']);
        Route::post('route', [ItineraryController::class, 'area_routes']);
        Route::post('save', [ItineraryController::class, 'store']);
        Route::get('view', [ItineraryController::class, 'view'])->name('itinerary_view');
        Route::get('search', [ItineraryController::class, 'search']);
        Route::get('display/{id}', [ItineraryController::class, 'display']);
        Route::get('edit/{id}', [ItineraryController::class, 'edit'])->name('itinerary_edit');
        Route::post('update/{id}', [ItineraryController::class, 'update']);
        Route::post('outlet_info', [ItineraryController::class, 'outlet_info']);
    });

    // Product Main Categories
    Route::group(['prefix' => 'product_main_category'], function () {
        Route::get('load', [ProductMainCategoryController::class, 'index'])->name('product_main_category');
        Route::post('save', [ProductMainCategoryController::class, 'save']);
        Route::get('search', [ProductMainCategoryController::class, 'search']);
        Route::get('view', [ProductMainCategoryController::class, 'view'])->name('product_main_category_view');
        Route::get('edit/{id}', [ProductMainCategoryController::class, 'edit'])->name('product_main_category_edit');
        Route::post('update/{id}', [ProductMainCategoryController::class, 'update']);
        Route::post('status', [ProductMainCategoryController::class, 'change_status']);
    });

    // Product Sub Categories
    Route::group(['prefix' => 'product_sub_category'], function () {
        Route::get('load', [ProductSubCategoryController::class, 'index'])->name('product_sub_category');
        Route::post('save', [ProductSubCategoryController::class, 'save']);
        Route::get('search', [ProductSubCategoryController::class, 'search']);
        Route::get('view', [ProductSubCategoryController::class, 'view'])->name('product_sub_category_view');
        Route::get('edit/{id}', [ProductSubCategoryController::class, 'edit'])->name('product_sub_category_edit');
        Route::post('update/{id}', [ProductSubCategoryController::class, 'update']);
        Route::post('status', [ProductSubCategoryController::class, 'change_status']);
    });

    // Product Master
    Route::group(['prefix' => 'product_master'], function () {
        Route::get('load', [ProductMasterController::class, 'index'])->name('product_master');
        Route::post('save', [ProductMasterController::class, 'save']);
        Route::get('search', [ProductMasterController::class, 'search']);
        Route::get('view', [ProductMasterController::class, 'view'])->name('product_master_view');
        Route::get('edit/{id}', [ProductMasterController::class, 'edit'])->name('product_master_edit');
        Route::post('update/{id}', [ProductMasterController::class, 'update']);
        Route::post('status', [ProductMasterController::class, 'change_status']);
    });

    // Product Sku
    Route::group(['prefix' => 'product_sku'], function () {
        Route::get('load', [ProductSkuController::class, 'index'])->name('product_sku');
        Route::post('save', [ProductSkuController::class, 'save']);
        Route::get('search', [ProductSkuController::class, 'search']);
        Route::get('view', [ProductSkuController::class, 'view'])->name('product_sku_view');
        Route::get('edit/{id}', [ProductSkuController::class, 'edit'])->name('product_sku_edit');
        Route::post('update/{id}', [ProductSkuController::class, 'update']);
        Route::post('status', [ProductSkuController::class, 'change_status']);
        Route::post('load_product_data', [ProductSkuController::class, 'load_product_data']);
    });

    // Product Gift Items
    Route::group(['prefix' => 'product_gift_item'], function () {
        Route::get('load', [ProductGiftItemController::class, 'index'])->name('product_gift_item');
        Route::post('save', [ProductGiftItemController::class, 'save']);
        Route::get('search', [ProductGiftItemController::class, 'search']);
        Route::get('view', [ProductGiftItemController::class, 'view'])->name('product_gift_item_view');
        Route::get('edit/{id}', [ProductGiftItemController::class, 'edit'])->name('product_gift_item_edit');
        Route::post('update/{id}', [ProductGiftItemController::class, 'update']);
        Route::post('status', [ProductGiftItemController::class, 'change_status']);
    });

    // Product POSM
    Route::group(['prefix' => 'product_posm'], function () {
        Route::get('load', [ProductPosmController::class, 'index'])->name('product_posm');
        Route::post('save', [ProductPosmController::class, 'save']);
        Route::get('search', [ProductPosmController::class, 'search']);
        Route::get('view', [ProductPosmController::class, 'view'])->name('product_posm_view');
        Route::get('edit/{id}', [ProductPosmController::class, 'edit'])->name('product_posm_edit');
        Route::post('update/{id}', [ProductPosmController::class, 'update']);
        Route::post('status', [ProductPosmController::class, 'change_status']);
    });

    // Line Free Issue
    Route::group(['prefix' => 'line_free'], function () {
        Route::get('load', [LineFreeIssueController::class, 'index'])->name('line_free_issue');
        Route::post('save', [LineFreeIssueController::class, 'save']);
        Route::get('view', [LineFreeIssueController::class, 'view']);
        Route::get('search', [LineFreeIssueController::class, 'search']);
        Route::get('purchase-free-products', [LineFreeIssueController::class, 'purchase_free_products']);
        Route::get('free-products', [LineFreeIssueController::class, 'free_products']);
        Route::get('status', [LineFreeIssueController::class, 'status']);
        Route::get('export', [LineFreeIssueController::class, 'export']);
    });

    // Adhoc Free Issue
    Route::group(['prefix' => 'adhoc_free'], function () {
        Route::get('load', [AdhocFreeIssueController::class, 'index'])->name('adhoc_free_issue');
        Route::post('save', [AdhocFreeIssueController::class, 'save']);
        Route::get('view', [AdhocFreeIssueController::class, 'view']);
        Route::get('search', [AdhocFreeIssueController::class, 'search']);
        Route::get('purchase-free-products', [AdhocFreeIssueController::class, 'purchase_free_products']);
        Route::get('status', [AdhocFreeIssueController::class, 'status']);
        Route::get('export', [AdhocFreeIssueController::class, 'export']);
    });

    // Assorted Free Issue
    Route::group(['prefix' => 'assorted_free'], function () {
        Route::get('load', [AssortedFreeIssueController::class, 'index'])->name('assorted_free_issue');
        Route::post('save', [AssortedFreeIssueController::class, 'save']);
        Route::get('view', [AssortedFreeIssueController::class, 'view']);
        Route::get('search', [AssortedFreeIssueController::class, 'search']);
        Route::get('purchase-free-products', [AssortedFreeIssueController::class, 'purchase_free_products']);
        Route::get('status', [AssortedFreeIssueController::class, 'status']);
        Route::get('export', [AssortedFreeIssueController::class, 'export']);
    });

    // Value Free Issue
    Route::group(['prefix' => 'value_free'], function () {
        Route::get('load', [ValueFreeIssueController::class, 'index'])->name('value_free_issue');
        Route::post('save', [ValueFreeIssueController::class, 'save']);
        Route::get('view', [ValueFreeIssueController::class, 'view']);
        Route::get('search', [ValueFreeIssueController::class, 'search']);
        Route::get('display/{id}', [ValueFreeIssueController::class, 'display']);
        Route::get('status', [ValueFreeIssueController::class, 'status']);
        Route::get('export', [ValueFreeIssueController::class, 'export']);
    });

    // Discount Flat
    Route::group(['prefix' => 'discount_flat'], function () {
        Route::get('load', [DiscountFlatContoller::class, 'index'])->name('discount_flat');
        Route::post('save', [DiscountFlatContoller::class, 'save']);
        Route::get('view', [DiscountFlatContoller::class, 'view']);
        Route::get('search', [DiscountFlatContoller::class, 'search']);
        Route::get('status', [DiscountFlatContoller::class, 'status']);
        Route::get('export', [DiscountFlatContoller::class, 'export']);
    });

    // Discount Special
    Route::group(['prefix' => 'discount'], function () {
        Route::get('load', [DiscountController::class, 'index'])->name('discount');
        Route::post('save', [DiscountController::class, 'save']);
        Route::get('view', [DiscountController::class, 'view']);
        Route::get('search', [DiscountController::class, 'search']);
        Route::get('edit/{id}', [DiscountController::class, 'edit']);
        Route::post('update/{id}', [DiscountController::class, 'update']);
        Route::get('status', [DiscountController::class, 'status']);
        Route::get('export', [DiscountController::class, 'export']);
    });

    // Discount Customer (In view use as Outlet)
    Route::group(['prefix' => 'discount_customer'], function () {
        Route::get('load', [DiscountCustomerController::class, 'index'])->name('discount_customer');
        Route::post('save', [DiscountCustomerController::class, 'save']);
        Route::get('view', [DiscountCustomerController::class, 'view']);
        Route::get('search', [DiscountCustomerController::class, 'search']);
        Route::get('status', [DiscountCustomerController::class, 'status']);
        Route::get('export', [DiscountCustomerController::class, 'export']);
        Route::post('sample_format', [DiscountCustomerController::class, 'sample_format']);
        Route::get('export_outlets', [DiscountCustomerController::class, 'export_outlets']);
    });

    // Promotion Hierarchy
    Route::group(['prefix' => 'free_issue_hierarchy'], function () {
        Route::get('load', [FreeIssueHierarchyController::class, 'index'])->name('free_issue_hierarchy');
        Route::post('free_issue_label', [FreeIssueHierarchyController::class, 'get_free_issue_label']);
        Route::post('load_details', [FreeIssueHierarchyController::class, 'load_details']);
        Route::post('download_csv', [FreeIssueHierarchyController::class, 'download_csv']);
        Route::post('save', [FreeIssueHierarchyController::class, 'save']);
        Route::get('view', [FreeIssueHierarchyController::class, 'view'])->name('free_issue_hierarchy_view');
        Route::get('search', [FreeIssueHierarchyController::class, 'search']);
        Route::get('edit/{id}', [FreeIssueHierarchyController::class, 'edit']);
        Route::post('update/{id}', [FreeIssueHierarchyController::class, 'update']);
        Route::get('common_label', [FreeIssueHierarchyController::class, 'common_label']);
    });

    // Promotion Priority
    Route::group(['prefix' => 'promotion_priority'], function () {
        Route::get('load', [PromotionPriorityController::class, 'index'])->name('promotion_priority');
        Route::post('save', [PromotionPriorityController::class, 'save']);
    });

    // APK Upload
    Route::group(['prefix' => 'apk'], function () {
        Route::get('upload', [ApkUploadController::class, 'index'])->name('apk_upload');
        Route::post('save', [ApkUploadController::class, 'save']);
        Route::get('view', [ApkUploadController::class, 'view']);
    });

    // System Component
    Route::group(['prefix' => 'system_components'], function () {
        Route::get('load', [SystemComponentController::class, 'index']);
        Route::post('save', [SystemComponentController::class, 'save']);
        Route::get('view', [SystemComponentController::class, 'view'])->name('system_component');
        Route::get('search', [SystemComponentController::class, 'search']);
        Route::get('edit/{id}', [SystemComponentController::class, 'edit']);
        Route::post('status', [SystemComponentController::class, 'change_status']);
        Route::get('get_reasons', [SystemComponentController::class, 'get_reasons']);
        Route::post('update/{id}', [SystemComponentController::class, 'update']);
    });

    // System Reason
    Route::group(['prefix' => 'system_reasons'], function () {
        Route::get('load', [SystemReasonsController::class, 'index']);
        Route::post('save', [SystemReasonsController::class, 'save']);
        Route::get('view', [SystemReasonsController::class, 'view'])->name('system_reason');
        Route::get('search', [SystemReasonsController::class, 'search']);
        Route::get('edit/{id}', [SystemReasonsController::class, 'edit']);
        Route::post('status', [SystemReasonsController::class, 'change_status']);
        Route::get('get_reasons', [SystemReasonsController::class, 'get_reasons']);
        Route::post('update/{id}', [SystemReasonsController::class, 'update']);
    });

    // Bank Details
    Route::group(['prefix' => 'bank_details'], function () {
        Route::get('load', [BankController::class, 'index']);
        Route::post('save', [BankController::class, 'save']);
        Route::get('view', [BankController::class, 'view'])->name('bank');
        Route::get('search', [BankController::class, 'search']);
        Route::get('edit/{id}', [BankController::class, 'edit']);
        Route::post('status', [BankController::class, 'change_status']);
        Route::get('get_branches', [BankController::class, 'get_branches']);
        Route::post('update/{id}', [BankController::class, 'update']);
    });

    // Payment Types
    Route::group(['prefix' => 'payment_types'], function () {
        Route::get('load', [PaymentTypeController::class, 'index']);
        Route::post('save', [PaymentTypeController::class, 'save']);
        Route::get('view', [PaymentTypeController::class, 'view'])->name('payment_type');
        Route::get('search', [PaymentTypeController::class, 'search']);
        Route::get('status', [PaymentTypeController::class, 'change_status']);
        Route::get('edit/{id}', [PaymentTypeController::class, 'edit']);
        Route::post('update/{id}', [PaymentTypeController::class, 'update']);
    });

    // Open stock
    Route::group(['prefix' => 'open_stock'], function () {
        Route::get('load', [OpenStockController::class, 'index'])->name('open_stock');
        Route::get('product', [OpenStockController::class, 'load_products']);
        Route::post('price', [OpenStockController::class, 'get_product_price']);
        Route::post('save', [OpenStockController::class, 'save']);
        Route::get('view', [OpenStockController::class, 'view'])->name('view_open_stock');
        Route::get('search', [OpenStockController::class, 'search']);
        Route::get('confirm/{id}', [OpenStockController::class, 'confirm'])->name('open_stock_confirm');
        Route::post('confirm_action', [OpenStockController::class, 'confirm_action']);
        Route::get('display/{id}', [OpenStockController::class, 'display'])->name('open_stock_display');
        Route::post('ck_availability', [OpenStockController::class, 'ck_availability']);
    });

    // Purchase Order
    Route::group(['prefix' => 'purchase_order'], function () {
        Route::get('load', [PurchaseOrderController::class, 'index']);
        Route::post('save', [PurchaseOrderController::class, 'save']);
        Route::get('view', [PurchaseOrderController::class, 'view'])->name('purchase_orders');;
        Route::get('search', [PurchaseOrderController::class, 'search']);
        Route::post('autocomplete', [PurchaseOrderController::class, 'autocomplete']);
        Route::get('display/{id}', [PurchaseOrderController::class, 'display'])->name('purchase_order_display');
        Route::get('text_create/{id}', [PurchaseOrderController::class, 'text_create'])->name('purchase_order_text_create');
        Route::post('text_create_action', [PurchaseOrderController::class, 'text_create_action']);
        Route::get('text_view/{id}', [PurchaseOrderController::class, 'text_view'])->name('purchase_order_text_view');
        Route::get('po_delete', [PurchaseOrderController::class, 'po_delete'])->name('po_delete');
        Route::get('edit/{id}', [PurchaseOrderController::class, 'po_edit'])->name('po_edit');
        Route::post('update/{po_id}', [PurchaseOrderController::class, 'update'])->name('po_update');
        Route::get('export/{po_id}', [PurchaseOrderController::class, 'po_export'])->name('po_export');
        Route::get('print/{po_id}', [PurchaseOrderController::class, 'print'])->name('po_print');
        Route::post('status', [StockPurchaseOrderController::class, 'change_status']);
        Route::get('load-po-in-po-view', [PurchaseOrderController::class, 'loadPoNumbers']);
        Route::get('po-load-to-table', [PurchaseOrderController::class, 'po_load_to_table']);
        Route::get('get-product-prices', [PurchaseOrderController::class, 'get_product_prices']);
        Route::get('approve/{po_id}', [PurchaseOrderController::class, 'approve'])->name('po_approve');
        Route::post('update_approve', [PurchaseOrderController::class, 'update_approve']);
    });

    // Sales Order
    Route::group(['prefix' => 'sales_order'], function () {
        Route::get('view', [SalesOrderController::class, 'index'])->name('view_sales_order');
        Route::get('search', [SalesOrderController::class, 'search']);
        Route::get('display/{id}', [SalesOrderController::class, 'display'])->name('sales_order_display');
        Route::get('print/{id}', [SalesOrderController::class, 'print'])->name('sales_order_print');
        Route::get('create_invoice/{id}', [SalesOrderController::class, 'create_invoice'])->name('sales_order_create_invoice');
        Route::post('save_invoice', [SalesOrderController::class, 'save_invoice']);
    });

    // Invoice
    Route::group(['prefix' => 'invoice'], function () {
        Route::get('view', [InvoiceController::class, 'index'])->name('view_invoice');
        Route::get('search', [InvoiceController::class, 'search']);
        Route::get('display/{id}', [InvoiceController::class, 'display'])->name('invoice_display');
        Route::get('print/{id}', [InvoiceController::class, 'print'])->name('invoice_print');

        Route::get('delivery_return/{id}', [InvoiceController::class, 'delivery_return'])->name('invoice_delivery_return');
    });

    // Common search filters
    Route::group(['prefix' => 'common'], function () {
        Route::post('load_region', [CommonFunctionController::class, 'load_region']);
        Route::post('load_area', [CommonFunctionController::class, 'load_area']);
        Route::post('load_route', [CommonFunctionController::class, 'load_route']);
        Route::post('load_customer', [CommonFunctionController::class, 'load_customer']);
        Route::post('load_shop', [CommonFunctionController::class, 'load_shop']);
        Route::post('load_distributor', [CommonFunctionController::class, 'load_distributor']);
        Route::post('load_rep', [CommonFunctionController::class, 'load_rep']);
        
        Route::post('load_sub_categories', [CommonFunctionController::class, 'load_sub_categories']);
        Route::post('load_product_masters', [CommonFunctionController::class, 'load_product_masters']);
        Route::post('load_product_skus', [CommonFunctionController::class, 'load_product_skus']);
        Route::post('load_product_posms', [CommonFunctionController::class, 'load_product_posms']);

        Route::post('check_stock_availability', [CommonFunctionController::class, 'check_stock_availability']);
        Route::post('check_free_issue_availability', [CommonFunctionController::class, 'check_free_issue_availability']);
        Route::post('check_free_issue_is_valid_or_not', [CommonFunctionController::class, 'check_free_issue_is_valid_or_not']);
        Route::post('handle_discount_flat', [CommonFunctionController::class, 'handleDiscountFlat']);
        Route::post('check_assorted', [CommonFunctionController::class, 'check_assorted']);

    });

    // Unproductive
    Route::group(['prefix' => 'unproductive'], function() {
        Route::get('visit_report', [UnproductiveController::class, 'visit_report']);
        Route::get('search', [UnproductiveController::class, 'search']);
        Route::get('export', [UnproductiveController::class, 'export']);
    });

    //GpsMap
    Route::group(['prefix' => 'gpsmap'], function() {
        Route::get('view', [GpsMapController::class, 'view']);
        Route::get('get_rep', [GpsMapController::class, 'get_rep']);
        Route::get('sr_get_attendance', [GpsMapController::class, 'sr_get_attendance']);
        Route::get('sr_routing_time', [GpsMapController::class, 'sr_routing_time']);
        Route::post('gps_info', [GpsMapController::class, 'gps_info']);
        Route::get('outlet_info', [GpsMapController::class, 'outlet_info']);
        Route::get('invoice_call_orders', [GpsMapController::class, 'invoice_call_orders']);
        Route::get('invoice_info', [GpsMapController::class, 'invoice_info']);
        Route::get('sales_orders_info', [GpsMapController::class, 'sales_orders_info']);
        Route::get('getAttendance', [GpsMapController::class, 'getAttendance']);
        Route::get('unproductive_visits', [GpsMapController::class, 'unproductive_visits']);

        Route::get('outlet', [GpsMapController::class, 'loadOutletMapView']);
        Route::get('outlet/getOutlets', [GpsMapController::class, 'getOutlets']);
        Route::get('outlet/getRegions', [GpsMapController::class, 'getRegions']);
        Route::get('outlet/getTerritory', [GpsMapController::class, 'getTerritory']);
        Route::get('outlet/getRoute', [GpsMapController::class, 'getRoute']);

    });

    //Competitor
    Route::group(['prefix' => 'competitor'], function() {
        Route::get('view', [CompetitorController::class, 'view'])->name('competitor_list');
        Route::get('search', [CompetitorController::class, 'search']);
        Route::get('get_products', [CompetitorController::class, 'get_products']);
        Route::get('create', [CompetitorController::class, 'create'])->name('competitor_register');
        Route::post('store', [CompetitorController::class, 'store']);
        Route::get('edit/{id}', [CompetitorController::class, 'edit']);
        Route::get('competitorProductCreate', [CompetitorController::class, 'competitorProductCreate'])->name('competitorProductCreate');
        Route::post('competitorProductStore', [CompetitorController::class, 'competitorProductStore']);
        Route::post('update/{id}', [CompetitorController::class, 'update']);

    });

    // Unplaned
    Route::group(['prefix' => 'unplaned'], function() {
        Route::get('view', [UnplanedVisitController::class, 'view'])->name('unplanned_view');
        Route::get('edit/{id}', [UnplanedVisitController::class, 'edit'])->name('unplaned_edit');
        Route::get('create', [UnplanedVisitController::class, 'create']);
        Route::get('search', [UnplanedVisitController::class, 'search']);
        Route::post('store', [UnplanedVisitController::class, 'store']);
        Route::post('update', [UnplanedVisitController::class, 'update']);
        Route::get('export', [UnplanedVisitController::class, 'export']);
        Route::post('status', [UnplanedVisitController::class, 'change_status']);

    });

    // Expenses
    Route::group(['prefix' => 'expense'], function() {
        Route::get('view', [ExpenseController::class, 'view'])->name('expense_view');
        Route::get('create', [ExpenseController::class, 'create'])->name('expense_create');
        Route::post('store', [ExpenseController::class, 'store']);
        Route::get('search', [ExpenseController::class, 'search']);
        Route::get('edit/{id}', [ExpenseController::class, 'edit'])->name('expense_edit');
        Route::post('update/{id}', [ExpenseController::class, 'update']);
        Route::post('check_expensetype', [ExpenseController::class, 'check_expensetype']);
    });

    // Message
    Route::group(['prefix' => 'message'], function() {
        Route::get('view', [MessageController::class, 'view'])->name('message_view');
        Route::get('create', [MessageController::class, 'create'])->name('message_create');
    });

    // VAT
    Route::group(['prefix' => 'vat'], function() {
        Route::get('view', [VatController::class, 'view'])->name('vat_view');
        Route::get('create', [VatController::class, 'create'])->name('vat_create');
        Route::post('check_vat_amount', [VatController::class, 'check_vat_amount']);
        Route::post('store', [VatController::class, 'store']);
        Route::get('search', [VatController::class, 'search']);
        Route::get('edit/{id}', [VatController::class, 'edit']);
        Route::post('update/{id}', [VatController::class, 'update']);
        Route::post('status', [VatController::class, 'change_status']);
    });

    // REF_ATTENDANCE
    Route::group(['prefix' => 'attendance'], function() {
        Route::get('view', [RepAttendanceController::class, 'view']);
        Route::post('load_rep_attendance_table', [RepAttendanceController::class, 'load_rep_attendance_table']);
        // Route::get('load_rep_attendance_table', [RepAttendanceController::class, 'load_rep_attendance_table']);
        Route::get('rep_attendance_excel', [RepAttendanceController::class, 'rep_attendance_excel']);
    });

    // DISTRIBUTOR
        Route::group(['prefix' => 'distributor'], function () {
        Route::get('view', [DistributorController::class, 'view'])->name('distributor_view');
        Route::get('search', [DistributorController::class, 'search']);
        Route::get('export', [DistributorController::class, 'export']);
    });

    // SALES REP
    Route::group(['prefix' => 'salesref'], function () {
        Route::get('view', [SalesRepController::class, 'view'])->name('sale_ref_view');
        Route::get('search', [SalesRepController::class, 'search']);
        Route::get('export', [SalesRepController::class, 'export']);
    });

    // ITEM REPORT
    Route::group(['prefix' => 'item'], function () {
        Route::get('view', [ItemController::class, 'view'])->name('item_view');
        Route::get('search', [ItemController::class, 'search']);
        Route::get('export', [ItemController::class, 'export']);
    });

     // REGION WISE CATEGORY REPORT
     Route::group(['prefix' => 'shop'], function () {
        Route::get('view', [ShopReportController::class, 'view'])->name('shop_view');
        Route::get('search', [ShopReportController::class, 'search']);
        Route::get('export', [ShopReportController::class, 'export']);
    });

     // AREA WISE CATEGORY REPORT
     Route::group(['prefix' => 'area_shop'], function () {
        Route::get('view', [AreaWiseShopController::class, 'view'])->name('area_shop_view');
        Route::post('load_area_wise_table', [AreaWiseShopController::class, 'load_area_wise_table']);
        // Route::get('search', [AreaWiseShopController::class, 'search']);
        Route::get('export', [AreaWiseShopController::class, 'export']);
    });

     // ROUTE WISE CATEGORY REPORT
     Route::group(['prefix' => 'route_shop'], function () {
        Route::get('view', [RouteWiseShopController::class, 'view'])->name('route_shop_view');
        Route::post('load_route_wise_table', [RouteWiseShopController::class, 'load_route_wise_table']);
        // Route::get('search', [RouteWiseShopController::class, 'search']);
        Route::get('export', [RouteWiseShopController::class, 'export']);
    });

    /**
     * * Test runs only
     */
    Route::group(['prefix' => 'test'], function () {

        Route::group(['prefix' => 'import'], function () {
            Route::get('customer/load', [ImportController::class, 'customer_load']);
            Route::get('customer/download_format', [ImportController::class, 'customer_download_format']);
            Route::post('customer/upload', [ImportController::class, 'customer_upload']);
        });

    });

});


