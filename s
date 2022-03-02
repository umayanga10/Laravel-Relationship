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

// zone

<?php

namespace App\Http\Controllers\Web\Organization;

use App\Http\Controllers\Controller;
use App\Models\Organization\SalesDivision;
use App\Models\Organization\Zone;
use App\Models\User\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Yajra\DataTables\Facades\DataTables;

class ZoneController extends Controller
{
    
    public function index() {
        $sales_division = SalesDivision::get();
        return view('contents.organization.zone.index', compact('sales_division'));
    }

    public function get_sales_division(Request $request) {
        $sales_division = SalesDivision::select(['sd_id', 'sd_name'])->get();
        return $sales_division;
    }

    public function save(Request $request) {
        DB::beginTransaction();
        try {

            for ($i = 1; $i <= $request->item_count; $i++) {
                if (isset($request['zone_code_' . $i])) {
                    $zone = Zone::create([
                        'sd_id' => $request['sales_division_' . $i],
                        'z_code' => $request['zone_code_' . $i],
                        'z_name' => $request['zone_name_' . $i]
                    ]);
                }
            }
            DB::commit();
            return redirect()->route('zone_registration')->with('success', 'RECORD HAS BEEN SUCCESSFULLY INSERTED!');
        } catch (\Exception $e) {
            DB::rollback();
            return redirect()->route('zone_registration')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY INSERTED!');
        }
    }

    public function view() {
        $sales_division = SalesDivision::get();
        return view('contents.organization.zone.view', compact('sales_division'));
    }

    public function search(Request $request) {
        if (isset(Auth::user()->u_tp_id)) {
        }
        $zone = DB::table('zones AS z')
            ->leftJoin('sales_divisions AS sd', 'sd.sd_id', 'z.sd_id')
            ->select([
                'sd.sd_name AS sd_name',
                'z.z_code as z_code',
                'z.z_name as z_name',
                DB::raw("DATE_FORMAT(z.created_at,'%Y-%m-%d') AS added_date"),
                DB::raw("DATE_FORMAT(z.created_at,'%H:%i:%s') AS added_time"),
                'z.z_id',
                'z.deleted_at'
            ])
            ->groupBy('z.z_id');
        return DataTables::of($zone)
            ->addColumn('edit', function ($zone) {
                if ($zone->deleted_at == NULL || $zone->deleted_at == "") {
                    $checkUserPermitedUrledit = User::checkUserPermitedUrl('ZONE EDIT');
                    if ($checkUserPermitedUrledit) {
                        return '<div style="text-align:center">
                        <a href="' . url('zone/edit', $zone->z_id) . '" target="_blank"><i style="color:#0998b0;font-size:18px" class="fas fa-pencil-alt fa-lg"></i></a>
                    </div>';
                    } else {
                        return '<div style="text-align:center">
                <a href="javascript:void(0);" ><i style="color:gray;font-size:18px" class="fas fa-pencil-alt fa-lg"></i></a>
            </div>';
                    }
                }
            })
            ->addColumn('status', function ($zone) {
                $checkUserPermitedUrldelete = User::checkUserPermitedUrl('ZONE DELETE');
                if ($zone->deleted_at == NULL || $zone->deleted_at == "") {
                    $current_status = 1;

                    if ($checkUserPermitedUrldelete) {
                        return '<div style="text-align:center"><a href="" onclick="change_status(' . $current_status . ',' . $zone->z_id . ')" class="btn btn-success btn-sm">Enable</a></div>';
                    } else {
                        return '<div style="text-align:center"><button disabled="disabled"  class="btn btn-success btn-sm">Enable</a></div>';
                    }
                } else {
                    $current_status = 0;
                    if ($checkUserPermitedUrldelete) {
                        return '<div style="text-align:center"><a href="" onclick="change_status(' . $current_status . ',' . $zone->z_id . ')" class="btn btn-danger btn-sm">Disable</a></div>';
                    } else {
                        return '<div style="text-align:center"><button disabled="disabled"  class="btn btn-danger btn-sm">Disable</a></div>';
                    }
                }
            })
            ->rawColumns(['edit', 'status'])
            ->filter(function ($query) use ($request) {
                if ($request->has('sales_division') && $request->get('sales_division') != "") {
                    $query->where('z.sd_id', '=', "{$request->get('sales_division')}");
                }
                if ($request->has('search') && !is_null($request->get('search')['value'])) {
                    $regex = $request->get('search')['value'];
                    return $query->where(function ($queryNew) use ($regex) {
                        $queryNew->where('z.z_code', 'like', '%' . $regex . '%')
                            ->orWhere('z.z_name', 'like', '%' . $regex . '%')
                            ->orWhere('sd.sd_name', 'like', '%' . $regex . '%')
                            ->orWhere('z.created_at', 'like', '%' . $regex . '%');
                    });
                }
            })
            ->make(true);
    }

    public function edit(Request $request) {
        $zone = Zone::find($request->id);
        $sales_division = SalesDivision::get();
        return view('contents.organization.zone.edit', compact('zone', 'sales_division'));
    }

    public function update(Request $request, $id) {
        $zone = Zone::find($id);
        $zone->sd_id = $request->get('sales_division_1');
        $zone->z_code = $request->get('zone_code_1');
        $zone->z_name = $request->get('zone_name_1');
        $zone->save();
        if ($zone) {
            return redirect()->route('zone_view')->with('success', 'RECORD HAS BEEN SUCCESSFULLY UPDATED!');
        } else {
            return redirect()->route('zone_view')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY UPDATED!');
        }
    }

    public function change_status(Request $request) {
        if ($request->status == 0) {
            Zone::withTrashed()->find($request->id)->restore();
            session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY RESTORED!');
        } elseif ($request->status == 1) {
            Zone::find($request->id)->delete();
            session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY DELETED!');
        }
    }
}
// area

<?php

namespace App\Http\Controllers\Web\Organization;

use App\Http\Controllers\Controller;
use App\Models\Organization\Area;
use App\Models\Organization\AreaTransferDetail;
use App\Models\Organization\Region;
use App\Models\Organization\Zone;
use App\Traits\UserArea;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Yajra\DataTables\Facades\DataTables;

class AreaController extends Controller
{

    use UserArea;
    
    public function index(){

        //generate territory number 
        $area_last_row = Area::orderBy('ar_id', 'desc')->first();
        if(empty($area_last_row->ar_id)){
            $area_code = '0';
        }else {
            $area_code = $area_last_row->ar_id;
        }
        $area_code_ = 'TE'.str_pad($area_code, 3, 0);

        $zone = Zone::get();
        $region = Region::get();
        return view('contents.organization.area.index', compact('zone','region', 'area_code_'));

    }

    public function get_zone(Request $request){
        $zone = Zone::select(['z_id','z_name'])->get();
        return $zone;
    }
    
    public function get_region(Request $request){
        $region = Region::select(['rg_id','rg_name'])->get();
        return $region;
    }

    public function save(Request $request){

        DB::beginTransaction();
        try {

            for ($i = 1; $i <= $request->item_count; $i++) {

                $area_code = "";
    
                //generate territory number 
                $area_last_row = Area::orderBy('ar_id', 'desc')->first();
                if(empty($area_last_row->ar_id)){
                    $area_code = '0';
                }else {
                    $area_code = $area_last_row->ar_id;
                }
                $area_code_ = 'TE'.str_pad($area_code, 3, 0);
    
                if(isset($request['area_name_' . $i])){
                    $area = Area::create([
                        'rg_id'=>$request['region_' . $i],
                        'z_id'=>$request['zone_' . $i],
                        'ar_code'=>$area_code_,
                        'ar_name'=>$request['area_name_' . $i]
                    ]);
    
                    // initial transfer titals
                    AreaTransferDetail::create([
                        'ar_id'=>$area->ar_id,
                        'rg_id'=>$request['region_' . $i],
                        'z_id'=> Region::getZoneId($request['region_' . $i]),
                        'transfer_time'=> 0,
                        'date_from'=> now(),
                        'date_to'=> config('sfa.enddate'),
                        'added_by'=> Auth::user()->u_id,
                    ]);
                }
            }
            DB::commit();
            return redirect()->route('area_registration')->with('success', 'RECORD HAS BEEN SUCCESSFULLY INSERTED!');
        } catch (\Exception $e) {
            DB::rollback();
            return redirect()->route('area_registration')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY INSERTED!');
        }
    }

    public function view(){
        $area = Area::withTrashed()->get();
        $zone = Zone::get();
        $region = Region::get();
        return view('contents.organization.area.view',compact('area', 'zone', 'region'));
    }

    public function search(Request $request) {

        $areas   = DB::table('areas as ar')
                ->join('regions as rg', 'rg.rg_id', 'ar.rg_id')
                ->select([
                    'ar.ar_id',
                    'ar.ar_code',
                    'ar.ar_name',
                    'rg.rg_name',
                    'rg.created_at',
                    'ar.deleted_at',
                ])
                ->orderBy('ar.ar_code');

                return DataTables::of($areas)
                ->addColumn('edit', function ($areas) {
                    return '<div style="text-align:center">
                                <a href="' . url('user/edit', $areas->ar_id) . '" target="_blank"><i style="color:#0998b0;font-size:18px" class="fas fa-pencil-alt fa-lg"></i></a>
                            </div>';
                })
                ->addColumn('status', function ($areas) {
                    if ($areas->deleted_at == NULL) {
                        $current_status = 1;
                        return '<div style="text-align:center"><a href="" onclick="change_status(' . $current_status . ',' . $areas->ar_id . ')" class="btn btn-success btn-sm">Enable</a></div>';
                    } else {
                        $current_status = 0;
                        return '<div style="text-align:center"><a href="" onclick="change_status(' . $current_status . ',' . $areas->ar_id . ')" class="btn btn-danger btn-sm">Disable</a></div>';
                    }
                })
                ->rawColumns(['edit', 'status'])
                ->filter(function ($query) use ($request) {

                    if ($request->has('z_id') && $request->get('z_id') != "") {
                        $query->where('rg.z_id', '=', "{$request->get('z_id')}");
                    }
                    if ($request->has('rg_id') && $request->get('rg_id') != "") {
                        $query->where('rg.rg_id', '=', "{$request->get('rg_id')}");
                    }

                    if ($request->has('search') && !is_null($request->get('search')['value'])) {
                        $regex = $request->get('search')['value'];
                        return $query->where(function ($queryNew) use ($regex) {
                            $queryNew->where('ar.ar_code', 'like', '%' . $regex . '%')
                                ->orWhere('ar.ar_name', 'like', '%' . $regex . '%')
                                ->orWhere('rg.rg_name', 'like', '%' . $regex . '%')
                                ->orWhere('rg.created_at', 'like', '%' . $regex . '%');
                        });
                    }
                })
                ->make(true);
    }

    public function edit(Request $request){
        $area = Area::find($request->id);
        $region = Region::get();
        return view('contents.organization.area.edit',compact('region','area'));
    }

    public function update(Request $request,$id){

        DB::beginTransaction();
        try {
            $area = Area::find($id);
            // $area->rg_id = $request->get('region_1'); // region change option disabled in view
            $area->ar_code = $request->get('area_code_1');
            $area->ar_name = $request->get('area_name_1');
            $area->save();
            DB::commit();
            return redirect()->route('area_view')->with('success', 'RECORD HAS BEEN SUCCESSFULLY UPDATED!');
        } catch (\Exception $e) {
            DB::rollback();
            return redirect()->route('area_view')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY UPDATED!');
        }
    }

    public function change_status(Request $request){
        if($request->status == 0){
            Area::withTrashed()->find($request->id)->restore();
            session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY RESTORED!');
        } elseif($request->status == 1){
            Area::find($request->id)->delete();
            session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY DELETED!');
        }
    }

    public function transfer() {
        $user = Auth::user();
        $allocatedUserArea = $this->getAllocatedAreaByUser($user);
        $zone = Zone::query();
        $region = Region::query();
        $area = Area::query();

        if($user->u_tp_id == config('sfa.asm')){
            $zone = $zone->whereIn('z_id',$allocatedUserArea->unique('z_id')->pluck('z_id')->all());
            $region = $region->whereIn('rg_id',$allocatedUserArea->unique('rg_id')->pluck('rg_id')->all());
            $area = $area->whereIn('ar_id',$allocatedUserArea->unique('ar_id')->pluck('ar_id')->all());
        }

        $zone = $zone->get();
        $region = $region->get();
        $area = $area->get();
        return view('contents.organization.area.transfer', [ 'zone' => $zone, 'region' => $region, 'area' => $area, ]);
    }

    public function transfer_search(Request $request) {
        $areas = DB::table('areas AS ar')
                    ->join('regions As rg', 'rg.rg_id', 'ar.rg_id')
                    ->whereNull('ar.deleted_at')
                    ->whereNull('rg.deleted_at')
                    ->orderBy('ar.created_at')
                    ->select([                
                        'ar.ar_id',
                        'ar.ar_code',
                        'ar.ar_name',
                        'ar.rg_id',
                        'rg.z_id',
                        DB::raw("DATE_FORMAT(ar.created_at,'%Y-%m-%d') AS added_date"),
                    ]);
        return DataTables::of($areas)
            ->addColumn('checkbox', function ($areas) {
                $btn = '<input type="checkbox" id="checkbox_'.$areas->ar_id.'" name="areas[]" value="'.$areas->ar_id.'" data-id="'.$areas->ar_id.'" class="single-checkbox" onclick="select_single_checkbox(event)"/>';
                return '<div style="text-align:center">'
                            .$btn.
                        '</div>';
            })
            ->rawColumns(['checkbox'])
            ->filter(function ($query) use ($request) {
                if ($request->has('z_id') && $request->get('z_id')  != '') {
                    $query->where('rg.z_id',  $request->get('z_id'));
                }
                if ($request->has('rg_id') && $request->get('rg_id')  != '') {
                    $query->where('ar.rg_id', '=', $request->get('rg_id'));
                }
                if ($request->has('ar_id') && $request->get('ar_id')  != '') {
                    $query->where('ar.ar_id', '=', $request->get('ar_id'));
                }
            })
            ->make(true);
    }

    public function transfer_save(Request $request) {
        // dd($request->all());
        DB::beginTransaction();
        try {

            foreach ($request->areas as $area) {
                $area_db = Area::where('ar_id', $area)->where('rg_id', $request->old_rg_id)->first();
                if (isset($area_db)) {
                    // update area
                    $area_db->update([
                        'rg_id' => $request->new_rg_id
                    ]);
                    
                    // get letest transfer details
                    $transfer_details = AreaTransferDetail::where('ar_id', $area)->latest()->first();

                    if (isset($transfer_details)) {

                        // set end date of current transfer
                        $transfer_details->update([
                            'date_to' => now()
                        ]);

                        // create new transfer details
                        AreaTransferDetail::create([
                            'ar_id'=> $area,
                            'rg_id'=> $request->old_rg_id,
                            'z_id'=> $request->old_z_id,
                            'transfer_time'=> $transfer_details->transfer_time+1,
                            'new_rg_id'=> $request->new_rg_id,
                            'new_z_id'=> $request->new_z_id,
                            'date_from'=> now(),
                            'date_to'=> config('sfa.enddate'),
                            'added_by'=> Auth::user()->u_id,
                        ]);
                    } else {
                        // create new transfer details, when initial transfer details are not available
                        AreaTransferDetail::create([
                            'ar_id'=> $area,
                            'rg_id'=> $request->old_rg_id,
                            'z_id'=> $request->old_z_id,
                            'transfer_time'=> 1,
                            'new_rg_id'=> $request->new_rg_id,
                            'new_z_id'=> $request->new_z_id,
                            'date_from'=> now(),
                            'date_to'=> config('sfa.enddate'),
                            'added_by'=> Auth::user()->u_id,
                        ]);
                    }
                }
            }

            DB::commit();
            return redirect()->route('area_transfer')->with('success', 'Territoty/s Transfer Success.');
        } catch (\Exception $e) {
            DB::rollback();
            // dd($e);
            return redirect()->route('area_transfer')->with('error', 'Territoty/s Transfer Failed.');
        }
    }

}
// outlet

<?php

namespace App\Http\Controllers\Web\Organization;

use App\Exports\Organization\CustomerExportExcel;
use App\Http\Controllers\Controller;
use App\Models\Organization\Area;
use App\Models\Organization\Customer;
use App\Models\Organization\CustomerCategory;
use App\Models\Organization\CustomerClass;
use App\Models\Organization\CustomerTransferDetail;
use App\Models\Organization\Region;
use App\Models\Organization\Route;
use App\Models\Organization\Zone;
use App\Traits\UserArea;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Maatwebsite\Excel\Facades\Excel;
use Yajra\DataTables\Facades\DataTables;

class CustomerController extends Controller
{
    
    use UserArea;

    public function index() {
        $customer_category = CustomerCategory::get();
        $customer_classification = CustomerClass::get();
        $route = Route::get();
        $zone = Zone::get();
        $region = Region::get();
        $area = Area::get();
        $cus_code = Customer::genCustomerCode();
        return view('contents.organization.customer.customer.index', compact('customer_category', 'customer_classification', 'route', 'cus_code', 'zone', 'region', 'area' ));
    }

    public function save(Request $request) {
        // dd($request->all());
        DB::beginTransaction();

        $validator = Validator::make($request->all(), [
            'outlet_image' => 'image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'customer_code' => 'required|string|max:255|unique:customers,cus_code',
        ]);

        if ($validator->fails()) {
            return redirect()->route('customer')->with('error', $validator->errors()->first())->withErrors($validator)->withInput();
        }
        else {

            try {

                if ($request->has('outlet_image')) {
                    $image = File::get($request->outlet_image);
                    $image_name = time().'.'.$request->outlet_image->extension();
                    Storage::put('/public/customer_img/'.date("Y").'/'.date("m").'/'.date("d").'/'.$image_name,$image);

                    $img_url = '/storage/customer_img/'.date("Y").'/'.date("m").'/'.date("d").'/'.$image_name;
                }
                else {
                    $img_url = null;
                }

                $customer = new Customer;
                $customer->cus_code = Customer::genCustomerCode();
                $customer->cus_name = $request->customer_name;
                $customer->cus_cat_id = $request->cus_cat_id;
                $customer->cus_class_id = $request->cus_class_id;
                $customer->r_id = $request->r_id;
                $customer->z_id = $request->z_id;
                $customer->rg_id = $request->rg_id;
                $customer->ar_id = $request->ar_id;
                $customer->cus_address = $request->cus_address;
                $customer->cus_phone = $request->cus_telephone;
                $customer->cus_mobile = $request->cus_mobile;
                $customer->cus_email = $request->cus_email;
                $customer->owner_name = $request->owner;
                $customer->owner_dob = $request->owner_dob;
                $customer->contact_person = $request->contact_person;
                $customer->contact_person_telephone = $request->contact_person_tp;
                $customer->cus_latitude = $request->cus_latitude;
                $customer->cus_longitude = $request->cus_longitude;
                $customer->image_url = $img_url;
                $customer->credit_limit = $request->credit_limit;
                $customer->dealer_board = $request->dealer_board_status;
                $customer->vat_availability = $request->vat_availability_status;            
                if ($request->vat_availability_status == '1') {
                    $customer->vat_no = $request->vat_no;
                }
                else {
                    $customer->vat_no = null;
                }            
                $customer->added_by = Auth::user()->u_id;
                $customer->cus_created_time = now();
                $customer->save();

                // initial transfer titals
                $r_id = $request->r_id;
                $ar_id = Route::getAreaId($r_id);
                $rg_id = Area::getRegionId($ar_id);
                $z_id = Region::getZoneId($rg_id);

                $cus_td = new CustomerTransferDetail;
                $cus_td->cus_id = $customer->cus_id;
                $cus_td->r_id = $r_id;
                $cus_td->ar_id = $ar_id;
                $cus_td->rg_id = $rg_id;
                $cus_td->z_id = $z_id;
                $cus_td->transfer_time = 0;
                $cus_td->date_from = now();
                $cus_td->date_to = config('sfa.enddate');
                $cus_td->added_by = Auth::user()->u_id;
                $cus_td->save();

                DB::commit();
                return redirect()->route('customer_view')->with('success', 'RECORD HAS BEEN SUCCESSFULLY INSERTED!');
            } catch (\Exception $e) {
                DB::rollback();
                // dd($e);
                return redirect()->route('customer')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY INSERTED!');
            }
        }
    }
    
    public function view() {
        $user = Auth::user();
        $allocatedUserArea = $this->getAllocatedAreaByUser($user);
        $zone = Zone::query();
        $region = Region::query();
        $area = Area::query();
        $route = Route::query();
        $customer = Customer::query();

        if($user->u_tp_id != config('sfa.sa')){
            if(sizeof($allocatedUserArea)>0){
                $zone = $zone->whereIn('z_id',$allocatedUserArea->unique('z_id')->pluck('z_id')->all());
                $region = $region->whereIn('rg_id',$allocatedUserArea->unique('rg_id')->pluck('rg_id')->all());
                $area = $area->whereIn('ar_id',$allocatedUserArea->unique('ar_id')->pluck('ar_id')->all());
                $route = $route->whereIn('ar_id',$allocatedUserArea->unique('ar_id')->pluck('ar_id')->all());
                $customer = $customer->whereIn('r_id',$allocatedUserArea->unique('r_id')->pluck('r_id')->all());
            }
        }

        $zone = $zone->get();
        $region = $region->get();
        $area = $area->get();
        $route = $route->get();
        $customer = $customer->get();
        return view('contents.organization.customer.customer.view', compact('zone', 'region', 'area', 'route', 'customer'));
    }

    public function search(Request $request) {
        $user = Auth::user();
        $allocatedUserArea = $this->getAllocatedAreaByUser($user);
        $customer = DB::table('zones AS z')
            ->join('regions AS rg', 'rg.z_id', 'z.z_id')
            ->join('areas AS a', 'a.rg_id', 'rg.rg_id')
            ->join('routes AS r', 'r.ar_id', 'a.ar_id')
            ->join('customers AS c', 'c.r_id', 'r.r_id')
            ->join('customer_categories AS cc', 'cc.cus_cat_id', 'c.cus_cat_id')
            ->leftJoin('customer_classes AS ccl', 'ccl.cus_class_id', 'c.cus_class_id')
            ->whereNull('z.deleted_at')
            ->whereNull('rg.deleted_at')
            ->whereNull('a.deleted_at')
            ->whereNull('r.deleted_at')
            ->whereNull('c.deleted_at')
            ->select([
                'z.z_name',
                'rg.rg_name',
                'a.ar_name',
                'r.r_name',
                'c.cus_code',
                'c.cus_sequence_no',
                'c.cus_name',
                'cc.cus_cat_name',
                'ccl.cus_class_description',
                'c.cus_address',
                'c.cus_phone',
                'c.cus_mobile',
                'c.cus_email',
                'c.owner_name',
                'c.contact_person',
                'c.contact_person_telephone',
                'c.vat_availability',
                'c.vat_no',
                'c.image_url',
                'c.cus_id',
                'c.created_at'
            ])
            ->groupBy('c.cus_id');
        return DataTables::of($customer)
            ->addColumn('vat_status', function ($customer) {
                if ($customer->vat_availability == 1) {
                    return '<span style="text-align:center">Yes</span>';
                } else {
                    return '<span style="text-align:center">No</span>';
                }
            })
            ->addColumn('edit', function ($customer) {
                return '<div style="text-align:center">
                <a href="' . url('customer/edit', $customer->cus_id) . '" target="_blank"><i style="color:#0998b0;font-size:18px" class="fas fa-pencil-alt fa-lg"></i></a>
            </div>';
            })
            ->addColumn('image_url', function ($customer) {
                $customer_id = $customer->cus_id;
                $img_url = asset($customer->image_url);
                $img_path = ltrim($customer->image_url,'storage/');
                if(Storage::disk('public')->exists($img_path)) {
                    $return_image = '<img src="' . $img_url . '" border="0" style="border-radius: 5px; cursor: pointer; max-width: 50px; max-height: 50px;" class="img-rounded" align="center"  data-bs-toggle="modal" data-bs-target="#myModal' . $customer_id . '" />
                                        <div class="modal fade" id="myModal' . $customer_id . '" tabindex="-1" role="dialog" aria-labelledby="outletImageTitle" aria-hidden="true">
                                            <div class="modal-dialog" role="document">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title" id="outletImageTitle">' . $customer->cus_name . ' - ' . $customer->cus_address . '</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body" style="text-align: center">
                                                        <img src="' . $img_url . '" border="0" width="400px" class="img-rounded" align="center" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>';
                }
                else {
                    $return_image = '<span style="text-align: center;color:red">No Record Found</span>';
                }

                return $return_image;
            })
            ->addColumn('asset', function ($customer) {
                return '<div style="text-align:center">
                <a href="#"><i style="color:#0998b0;font-size:18px" class="fas fa-list fa-lg"></i></a>
            </div>';
            })
            ->addColumn('delete', function ($customer) {
                return '<div style="text-align:center">
                <a href="#" onclick="delete_customer(' . $customer->cus_id . ');"><i style="color:red;font-size:18px" class="fas fa-trash fa-lg"></i></a>
            </div>';
            })
            ->rawColumns(['vat_status', 'edit', 'image_url', 'asset', 'delete'])
            ->filter(function ($query) use ($request,$user,$allocatedUserArea) {
                if ($request->has('z_id') && $request->get('z_id') != "") {
                    $query->where('rg.z_id', '=', "{$request->get('z_id')}");
                }
                if ($request->has('rg_id') && $request->get('rg_id') != "") {
                    $query->where('a.rg_id', '=', "{$request->get('rg_id')}");
                }
                if ($request->has('ar_id') && $request->get('ar_id') != "") {
                    $query->where('r.ar_id', '=', "{$request->get('ar_id')}");
                }
                if ($request->has('r_id') && $request->get('r_id') != "") {
                    $query->where('c.r_id', '=', "{$request->get('r_id')}");
                }
                if($user->u_tp_id != config('sfa.sa')){
                    if(sizeof($allocatedUserArea)>0){
                        $query->whereIn('c.r_id',$allocatedUserArea->unique('r_id')->pluck('r_id')->all());
                    }
                }
                if ($request->has('search') && !is_null($request->get('search')['value'])) {
                    $regex = $request->get('search')['value'];
                    return $query->where(function ($queryNew) use ($regex) {
                        $queryNew->where('z.z_name', 'like', '%' . $regex . '%')
                            ->orWhere('rg.rg_name', 'like', '%' . $regex . '%')
                            ->orWhere('a.ar_name', 'like', '%' . $regex . '%')
                            ->orWhere('r.r_name', 'like', '%' . $regex . '%')
                            ->orWhere('c.cus_code', 'like', '%' . $regex . '%')
                            ->orWhere('c.cus_name', 'like', '%' . $regex . '%')
                            ->orWhere('cc.cus_cat_name', 'like', '%' . $regex . '%')
                            ->orWhere('ccl.cus_class_description', 'like', '%' . $regex . '%')
                            ->orWhere('c.cus_address', 'like', '%' . $regex . '%')
                            ->orWhere('c.cus_phone', 'like', '%' . $regex . '%')
                            ->orWhere('c.cus_mobile', 'like', '%' . $regex . '%')
                            ->orWhere('c.cus_email', 'like', '%' . $regex . '%')
                            ->orWhere('c.owner_name', 'like', '%' . $regex . '%')
                            ->orWhere('c.contact_person', 'like', '%' . $regex . '%')
                            ->orWhere('c.contact_person_telephone', 'like', '%' . $regex . '%')
                            ->orWhere('c.vat_no', 'like', '%' . $regex . '%');
                    });
                }
            })
            ->make(true);
    }

    public function edit($id) {
        $customer = Customer::find($id);
        $customer_category = CustomerCategory::get();
        $customer_classification = CustomerClass::get();
        $route = Route::get();
        return view('contents.organization.customer.customer.edit', compact('customer', 'customer_category', 'customer_classification', 'route'));
    }

    public function update(Request $request, $id) {
        // dd($request->all());

        $validator = Validator::make($request->all(), [
            'cus_sequence_no' => 'required',
        ]);

        if ($validator->fails())
            return redirect()->route('customer')->with('error', $validator->errors()->first())->withErrors($validator)->withInput();

        DB::beginTransaction();
        try {

            $current_sequence = null;
            $new_sequence = $request->cus_sequence_no;
            $sequence_route = $request->sequence_route;
            $customer_count = Customer::where('r_id', $sequence_route)->count();

            if ($new_sequence <= 1) {
                $current_sequence =  1;
            } else if ($new_sequence > 1) {
                $current_sequence =  $new_sequence;
            }

            $customer_exists = Customer::where('r_id', $sequence_route)->where('cus_sequence_no', $current_sequence)->where('cus_id', '!=', $id)->get();
            if (count($customer_exists) > 0) {
                $customers = Customer::where('r_id', $sequence_route)
                                        ->whereBetween('cus_sequence_no', [$current_sequence, $customer_count])
                                        ->get();
                foreach ($customers as $cus) {
                    $cus->update([
                        'cus_sequence_no' => $cus->cus_sequence_no + 1
                    ]);
                }
            }

            $customer = Customer::find($id);
            $customer->cus_code = $request->customer_code;
            $customer->cus_sequence_no = $request->cus_sequence_no;
            $customer->cus_name = $request->customer_name;
            $customer->cus_cat_id = $request->cus_cat_id;
            $customer->cus_class_id = $request->cus_class_id;
            // $customer->r_id = $request->r_id; // route change option disabled in view
            $customer->cus_address = $request->cus_address;
            $customer->cus_phone = $request->cus_telephone;
            $customer->cus_mobile = $request->cus_mobile;
            $customer->cus_email = $request->cus_email;
            $customer->owner_name = $request->owner;
            $customer->owner_dob = $request->owner_dob;
            $customer->contact_person = $request->contact_person;
            $customer->contact_person_telephone = $request->contact_person_tp;
            $customer->credit_limit = $request->credit_limit;
            $customer->dealer_board = $request->dealer_board_status;
            $customer->vat_availability = $request->vat_availability_status;
            if ($request->vat_availability_status == '1') {
                $customer->vat_no = $request->vat_no;
            }
            $customer->save();

            DB::commit();
            return redirect()->route('customer_view')->with('success', 'RECORD HAS BEEN SUCCESSFULLY UPDATED!');
        } catch (\Exception $e) {
            DB::rollback();
            // dd($e);
            return redirect()->route('customer_view')->with('error', 'RECORD HAS NOT BEEN SUCCESSFULLY UPDATED!');
        }
    }

    function distroy(Request $request) {
        Customer::find($request->id)->delete();
        return session()->flash('success', 'RECORD HAS BEEN SUCCESSFULLY DELETED!');
    }

    public function export(Request $request) {
        $customer = DB::table('zones AS z')
            ->join('regions AS rg', 'rg.z_id', 'z.z_id')
            ->join('areas AS a', 'a.rg_id', 'rg.rg_id')
            ->join('routes AS r', 'r.ar_id', 'a.ar_id')
            ->join('customers AS c', 'c.r_id', 'r.r_id')
            ->join('customer_categories AS cc', 'cc.cus_cat_id', 'c.cus_cat_id')
            ->join('customer_classes AS ccl', 'ccl.cus_class_id', 'c.cus_class_id')
            ->whereNull('z.deleted_at')
            ->whereNull('rg.deleted_at')
            ->whereNull('a.deleted_at')
            ->whereNull('r.deleted_at')
            ->whereNull('c.deleted_at')
            ->select([
                'z.z_name',
                'rg.rg_name',
                'a.ar_name',
                'r.r_name',
                'c.cus_code',
                'c.cus_name',
                'cc.cus_cat_name',
                'ccl.cus_class_description',
                'c.cus_address',
                'c.cus_phone',
                'c.cus_mobile',
                'c.cus_email',
                'c.owner_name',
                'c.contact_person',
                'c.contact_person_telephone',
                'c.vat_availability',
                'c.vat_no',
                'c.image_url',
                'c.cus_id',
                'c.created_at'
            ])
            ->groupBy('c.cus_id');

        if ($request->has('z_id') && $request->get('z_id') != "") {
            $customer->where('rg.z_id', '=', "{$request->get('z_id')}");
        }
        if ($request->has('rg_id') && $request->get('rg_id') != "") {
            $customer->where('a.rg_id', '=', "{$request->get('rg_id')}");
        }
        if ($request->has('ar_id') && $request->get('ar_id') != "") {
            $customer->where('r.ar_id', '=', "{$request->get('ar_id')}");
        }
        if ($request->has('r_id') && $request->get('r_id') != "") {
            $customer->where('c.r_id', '=', "{$request->get('r_id')}");
        }
        if ($request->has('search') && !is_null($request->get('search')['value'])) {
            $regex = $request->get('search')['value'];
            return $customer->where(function ($queryNew) use ($regex) {
                $queryNew->where('z.z_name', 'like', '%' . $regex . '%')
                    ->orWhere('rg.rg_name', 'like', '%' . $regex . '%')
                    ->orWhere('a.ar_name', 'like', '%' . $regex . '%')
                    ->orWhere('r.r_name', 'like', '%' . $regex . '%')
                    ->orWhere('c.cus_code', 'like', '%' . $regex . '%')
                    ->orWhere('c.cus_name', 'like', '%' . $regex . '%')
                    ->orWhere('cc.cus_cat_name', 'like', '%' . $regex . '%')
                    ->orWhere('ccl.cus_class_description', 'like', '%' . $regex . '%')
                    ->orWhere('c.cus_address', 'like', '%' . $regex . '%')
                    ->orWhere('c.cus_phone', 'like', '%' . $regex . '%')
                    ->orWhere('c.cus_mobile', 'like', '%' . $regex . '%')
                    ->orWhere('c.cus_email', 'like', '%' . $regex . '%')
                    ->orWhere('c.owner_name', 'like', '%' . $regex . '%')
                    ->orWhere('c.contact_person', 'like', '%' . $regex . '%')
                    ->orWhere('c.contact_person_telephone', 'like', '%' . $regex . '%')
                    ->orWhere('c.vat_no', 'like', '%' . $regex . '%');
            });
        }

        return Excel::download(new CustomerExportExcel($customer->get()), 'outlets.xlsx');
    }

    public function transfer() {
        $user = Auth::user();
        $allocatedUserArea = $this->getAllocatedAreaByUser($user);
        $zone = Zone::query();
        $region = Region::query();
        $area = Area::query();
        $route = Route::query();
        $customer = Customer::query();

        if($user->u_tp_id == config('sfa.asm')){
            $zone = $zone->whereIn('z_id',$allocatedUserArea->unique('z_id')->pluck('z_id')->all());
            $region = $region->whereIn('rg_id',$allocatedUserArea->unique('rg_id')->pluck('rg_id')->all());
            $area = $area->whereIn('ar_id',$allocatedUserArea->unique('ar_id')->pluck('ar_id')->all());
            $route = $route->whereIn('ar_id',$allocatedUserArea->unique('ar_id')->pluck('ar_id')->all());
            $customer = $customer->whereIn('r_id',$allocatedUserArea->unique('r_id')->pluck('r_id')->all());
        }

        $zone = $zone->get();
        $region = $region->get();
        $area = $area->get();
        $route = $route->get();
        $customer = $customer->get();
        return view('contents.organization.customer.customer.transfer', [ 'zone' => $zone, 'region' => $region, 'area' => $area, 'route' => $route, 'customer' => $customer, ]);
    }

    public function transfer_search(Request $request) {
        $customers = DB::table('customers AS cus')
                    ->join('routes AS r', 'r.r_id', 'cus.r_id')
                    ->join('areas As ar', 'ar.ar_id', 'r.ar_id')
                    ->join('regions As rg', 'rg.rg_id', 'ar.rg_id')
                    ->leftjoin('customer_categories as cca', 'cca.cus_cat_id', 'cus.cus_cat_id')
                    ->leftjoin('discount_customer_details as dcd', 'dcd.cus_id', 'cus.cus_id')
                    ->leftjoin('discount_customers as disc', 'disc.discount_id', 'dcd.discount_id')
                    ->where(function($query){
                        $query->where('dcd.customer_status', '=', '0')
                        ->orwhere(function($query){
                            $query->whereNull('dcd.customer_status');
                        });
                    })
                    ->whereNull('r.deleted_at')
                    ->whereNull('ar.deleted_at')
                    ->whereNull('rg.deleted_at')
                    ->orderBy('r.created_at')
                    ->select([                
                        'cus.cus_id',
                        'cus.cus_code',
                        'cus.cus_name',
                        'cus.cus_address',
                        'cus.owner_name',
                        'cus.r_id',
                        'r.ar_id',
                        'r.r_name',
                        'ar.rg_id',
                        'rg.z_id',
                        'cca.cus_cat_name',
                        'disc.discount_label',
                        DB::raw("CONCAT(dcd.discount, '%') AS discount"),
                        DB::raw("DATE_FORMAT(cus.cus_created_time,'%Y-%m-%d') AS added_date"),
                    ]);
        return DataTables::of($customers)
            ->addColumn('checkbox', function ($customers) {
                $btn = '<input type="checkbox" id="checkbox_'.$customers->cus_id.'" name="customers[]" value="'.$customers->cus_id.'" data-id="'.$customers->cus_id.'" class="single-checkbox" onclick="select_single_checkbox(event)"/>';
                return '<div style="text-align:center">'
                            .$btn.
                        '</div>';
            })
            ->rawColumns(['checkbox'])
            ->filter(function ($query) use ($request) {
                if ($request->has('z_id') && $request->get('z_id')  != '') {
                    $query->where('rg.z_id',  $request->get('z_id'));
                }
                if ($request->has('rg_id') && $request->get('rg_id')  != '') {
                    $query->where('ar.rg_id', '=', $request->get('rg_id'));
                }
                if ($request->has('ar_id') && $request->get('ar_id')  != '') {
                    $query->where('ar.ar_id', '=', $request->get('ar_id'));
                }
                if ($request->has('r_id') && $request->get('r_id')  != '') {
                    $query->where('r.r_id', '=', $request->get('r_id'));
                }
                if ($request->has('cus_id') && $request->get('cus_id')  != '') {
                    $query->where('cus.cus_id', '=', $request->get('cus_id'));
                }
            })
            ->make(true);
    }

    public function transfer_save(Request $request) {
        // dd($request->all());
        DB::beginTransaction();
        try {

            foreach ($request->customers as $customer) {
                $customer_db = Customer::where('cus_id', $customer)->where('r_id', $request->old_r_id)->first();
                if (isset($customer_db)) {
                    // update customer
                    $customer_db->update([
                        'r_id' => $request->new_r_id
                    ]);
                    
                    // get letest transfer details
                    $transfer_details = CustomerTransferDetail::where('cus_id', $customer)->latest()->first();

                    if (isset($transfer_details)) {

                        // set end date of current transfer
                        $transfer_details->update([
                            'date_to' => now()
                        ]);

                        // create new transfer details
                        CustomerTransferDetail::create([
                            'cus_id'=> $customer,
                            'r_id'=> $request->old_r_id,
                            'ar_id'=> $request->old_ar_id,
                            'rg_id'=> $request->old_rg_id,
                            'z_id'=> $request->old_z_id,
                            'transfer_time'=> $transfer_details->transfer_time+1,
                            'new_r_id'=> $request->new_r_id,
                            'new_ar_id'=> $request->new_ar_id,
                            'new_rg_id'=> $request->new_rg_id,
                            'new_z_id'=> $request->new_z_id,
                            'date_from'=> now(),
                            'date_to'=> config('sfa.enddate'),
                            'added_by'=> Auth::user()->u_id,
                        ]);
                    } else {
                        // create new transfer details, when initial transfer details are not available
                        CustomerTransferDetail::create([
                            'cus_id'=> $customer,
                            'r_id'=> $request->old_r_id,
                            'ar_id'=> $request->old_ar_id,
                            'rg_id'=> $request->old_rg_id,
                            'z_id'=> $request->old_z_id,
                            'transfer_time'=> 1,
                            'new_r_id'=> $request->new_r_id,
                            'new_ar_id'=> $request->new_ar_id,
                            'new_rg_id'=> $request->new_rg_id,
                            'new_z_id'=> $request->new_z_id,
                            'date_from'=> now(),
                            'date_to'=> config('sfa.enddate'),
                            'added_by'=> Auth::user()->u_id,
                        ]);
                    }
                }
            }

            DB::commit();
            return redirect()->route('customer_transfer')->with('success', 'Customer/s Transfer Success.');
        } catch (\Exception $e) {
            DB::rollback();
            dd($e);
            return redirect()->route('customer_transfer')->with('error', 'Customer/s Transfer Failed.');
        }
    }
  
}


