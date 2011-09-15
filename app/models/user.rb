class User < ActiveRecord::Base
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  attr_accessible :user_phenotypes_attributes, :variation, :characteristic, :name, :password_confirmation, :password, :email, :description, :homepages, :homepages_attributes,:avatar, :phenotype_creation_counter, :phenotype_additional_counter
	
	
	acts_as_authentic # call on authlogic
	after_create :make_standard_phenotypes

	# dependent so stuff gets destroyed on delete
	has_many :user_phenotypes, :dependent => :destroy
	has_many :phenotypes, :through => :user_phenotypes
	has_many :genotypes, :dependent => :destroy
	# user_snps needs some extra-logic to decrease the counters
	has_many :user_snps, :dependent => :destroy
	has_many :snps, :through => :user_snps
	has_many :homepages, :dependent => :destroy
	has_many :messages
	has_many :user_achievements, :dependent => :destroy
	has_many :achievements, :through => :user_achievements
	has_many :snp_comments
	has_many :phenotype_comments

	# needed to edit several user_phenotypes at once, add and delete, and not empty
	accepts_nested_attributes_for :homepages, :allow_destroy => true
	accepts_nested_attributes_for :user_phenotypes, :allow_destroy => true

	searchable do
		text :description, :name, :email
	end

	def deliver_password_reset_instructions!
		reset_perishable_token!
		Notifier.deliver_password_reset_instructions(self)
	end

   def check_if_phenotype_exists(charact)
		 # checks so we don't create duplicate phenotypes
	   if Phenotype.find_by_characteristic(charact) != nil
		   return true
	   else
		   return false
	   end
   end

   def check_and_make_standard_phenotypes(charact)
		 # checks whether phenotype exists, creates one if doesn't,
		 # creates fitting user_phenotype in both cases
	   if check_if_phenotype_exists(charact) == true
		   @phen_id = Phenotype.find_by_characteristic(charact).id
		   UserPhenotype.create(:phenotype_id => @phen_id, :variation => '', :user_id => id)
	   else
		   @phen_id = Phenotype.create(:characteristic => charact,:known_phenotypes => []).id
     	   UserPhenotype.create(:phenotype_id => @phen_id, :variation => '', :user_id => id)
	   end
   end
  	
   def make_standard_phenotypes
	   check_and_make_standard_phenotypes('Hair color')
	   check_and_make_standard_phenotypes('Eye color')
	   check_and_make_standard_phenotypes('Skin color')
	   check_and_make_standard_phenotypes('Blood type')
   end

end
