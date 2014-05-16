#include "pbook.h"
#include "tree_utils.h"


static void GEAddNewNonleafNode ( struct GE_treeNode *old_T, int old_tree_length, 
								   struct GE_treeNode *new_T, int node_index, 
								   int new_nonleaf_value, int cut_dir, int new_value );
static void subTAddNewNonleafNode ( struct subT_treeNode *old_T, 
									 int old_tree_length, 
									 struct subT_treeNode *new_T, 
									 int node_index, int new_nonleaf_value, 
									 int cut_dir, int new_value );
static void checkSpacing ( struct config_params *cp, double spacing );
static void verifyValueIsUnique ( struct GE_treeNode *GE_tree, int num_leaves,
								  int value );
static struct page_schedule_entry *pageScheduleEntryFromGAIndex ( int GA_index,
																  struct page_schedule *pg_sched,
																  struct graphic_assembly_list *GA_list );
static int GEsAreSimilar ( struct config_params *cp,
						   struct GE_identifier *GE_ID1, struct GE_identifier *GE_ID2,
						   struct page_schedule *pg_sched,
						   struct graphic_assembly_list *GA_list );
static int photosAreFairlySimilar ( struct config_params *cp,
									struct photo *ph1, struct photo *ph2,
									struct pbook_page *page );
static void determineRowColConfigs ( struct photo_seq *ph_seq );
static void verifyGA ( struct graphic_assembly *GA );

void reflectSubTTreeTopToBottom ( struct pbook_page *page, struct subT_treeNode *node )
{
	struct subT_treeNode *L_child, *R_child;
	int temp;

	if ( node->value > 0 ) {
		return;
	}

	if ( node->cut_dir == HORIZ ) {
		temp = node->Lchild;
		node->Lchild = node->Rchild;
		node->Rchild = temp;
	}

	L_child = subTTreeNodeFromTreeValue ( page, node->Lchild );
	reflectSubTTreeTopToBottom ( page, L_child );

	R_child = subTTreeNodeFromTreeValue ( page, node->Rchild );
	reflectSubTTreeTopToBottom ( page, R_child );
}

void reflectSubTTreeLeftToRight ( struct pbook_page *page, struct subT_treeNode *node )
{
	struct subT_treeNode *L_child, *R_child;
	int temp;

	if ( node->value > 0 ) {
		return;
	}

	if ( node->cut_dir == VERT ) {
		temp = node->Lchild;
		node->Lchild = node->Rchild;
		node->Rchild = temp;
	}

	L_child = subTTreeNodeFromTreeValue ( page, node->Lchild );
	reflectSubTTreeLeftToRight ( page, L_child );

	R_child = subTTreeNodeFromTreeValue ( page, node->Rchild );
	reflectSubTTreeLeftToRight ( page, R_child );
}

int pseudoRandomNumber ( int max )
{
	// this code is after Numerical Recipes in C (NR), by Press, 
	// Flannery, Teukolsky, and Vetterling; see Sec. 7.1 in the 1990 
	// edition. the recursion is well known and the name of its form
	// is "linear congruential generator," or LCG

	// generate a pseudorandom number between 0 and max, inclusive

	int min, num;

	min = 0;

	// this recursion generates the pseudorandom sequence
	pseudorandom_val = ((pseudorandom_val*rand_a)+rand_c)%rand_m;

	num = min + ( ((max-min+1)*((int)(pseudorandom_val))) / ((int)(rand_m)) );
	return num;
}

double pseudoRandomZeroOne ( )
{
	double x;

	// this code is after Numerical Recipes in C (NR), by Press, 
	// Flannery, Teukolsky, and Vetterling; see Sec. 7.1 in the 1990 
	// edition. the recursion is well known and the name of its form
	// is "linear congruential generator," or LCG

	// this recursion generates the pseudorandom sequence
	pseudorandom_val = ((pseudorandom_val*rand_a)+rand_c)%rand_m;

	x = ( ( double ) ( pseudorandom_val ) ) / ( ( double ) ( rand_m ) );

	return x;
}

void seedPseudoRandomNumber ( int seed )
{
	if ( seed >= ((int)(rand_m)) ) {
		seed = seed%((int)(rand_m));
	}

	pseudorandom_val = ( unsigned long ) ( seed );
}

static void GEAddNewNonleafNode ( struct GE_treeNode *old_T, int old_tree_length, 
								   struct GE_treeNode *new_T, int node_index, 
								   int new_nonleaf_value, int cut_dir, int new_value )
{
	// displace node with index node_index in the old tree
	// by introducing a cut with the specified direction at that point; 
	// let the subtree rooted at node_index be one child, 
	// and let the new node be the other child

	// new_nonleaf_value is the value of the nonleaf node being added
	// and new_value is the value of the child of the nonleaf node
	// being added ... at this point it does not matter 
	// whether this child will be a leaf or a nonleaf
	// (although we could look at its value and figure that out) 

	int i, parent_index;
	struct GE_treeNode *disp_node, *new_nonleaf, *disp_node_parent;

	disp_node = & ( old_T[node_index] );
	if ( disp_node->value == disp_node->parent ) {

		if ( node_index != 0 ) {
			exitOrException("\nexpected root node to have index zero");
		}

		// displacing the root node ...

		// copy the old tree into the new tree, leaving room 
		// at the beginning for the new root node.
		// copying backwards since new_T may equal old_T 
		// (i.e. we may be doing this in-place) 
		for ( i = old_tree_length - 1; i >= 0; i-- ) {
			new_T[i+1] = old_T[i];
		}

		// relative to the new tree, 
		// the displaced node is shifted over one place
		disp_node = & ( new_T[node_index+1] );

		// define the new root node 
		new_nonleaf = & ( new_T[0] );
		new_nonleaf->value   = new_nonleaf_value;
		new_nonleaf->parent  = new_nonleaf_value;
	}
	else {

		// displacing a non-root node ...

		// copy the old tree into the new tree if necessary
		if ( new_T != old_T ) {
			for ( i = 0; i < old_tree_length; i++ ) {
				new_T[i] = old_T[i];
			}
		}

		disp_node = & ( new_T[node_index] );

		// set the child value in the parent of the node being displaced
		parent_index = GEGetTreeIndex ( new_T, old_tree_length, disp_node->parent );
		disp_node_parent = & ( new_T[parent_index] );
		if ( disp_node_parent->Lchild == disp_node->value ) {
			disp_node_parent->Lchild = new_nonleaf_value;
		}
		else if ( disp_node_parent->Rchild == disp_node->value ) {
			disp_node_parent->Rchild = new_nonleaf_value;
		}
		else{exitOrException("\nerror adding image to tree");}

		// define the new nonleaf node
		new_nonleaf = & ( new_T[old_tree_length] );
		new_nonleaf->value = new_nonleaf_value;
		new_nonleaf->parent = disp_node_parent->value;
	}

	// set the new parent for the node we are displacing 
	disp_node->parent = new_nonleaf_value;

	// set the cut direction and pointers to children of the new nonleaf 
	new_nonleaf->cut_dir = cut_dir;
	new_nonleaf->Lchild  = disp_node->value;
	new_nonleaf->Rchild  = new_value;

	// at this point the new nonleaf node is ready, and the 
	// displaced node is appropriately modified ... but we still 
	// need to incorporate the other child of the new nonleaf node
}


static void subTAddNewNonleafNode ( struct subT_treeNode *old_T, 
									 int old_tree_length, 
									 struct subT_treeNode *new_T, 
									 int node_index, int new_nonleaf_value, 
									 int cut_dir, int new_value )
{
	// displace node with index node_index in the old tree
	// by introducing a cut with the specified direction at that point; 
	// let the subtree rooted at node_index be one child, 
	// and let the new node be the other child

	// new_nonleaf_value is the value of the nonleaf node being added
	// and new_value is the value of the child of the nonleaf node
	// being added ... at this point it does not matter 
	// whether this child will be a leaf or a nonleaf
	// (although we could look at its value and figure that out) 

	int i, parent_index;
	struct subT_treeNode *disp_node, *new_nonleaf, *disp_node_parent;

	disp_node = & ( old_T[node_index] );
	if ( disp_node->value == disp_node->parent ) {

		if ( node_index != 0 ) {
			exitOrException("\nexpected root node to have index zero");
		}

		// displacing the root node ...

		// copy the old tree into the new tree, leaving room 
		// at the beginning for the new root node.
		// copying backwards since new_T may equal old_T 
		// (i.e. we may be doing this in-place) 
		for ( i = old_tree_length - 1; i >= 0; i-- ) {
			new_T[i+1] = old_T[i];
		}

		// relative to the new tree, 
		// the displaced node is shifted over one place
		disp_node = & ( new_T[node_index+1] );

		// define the new root node 
		new_nonleaf = & ( new_T[0] );
		new_nonleaf->value   = new_nonleaf_value;
		new_nonleaf->parent  = new_nonleaf_value;
	}
	else {

		// displacing a non-root node ...

		// copy the old tree into the new tree if necessary
		if ( new_T != old_T ) {
			for ( i = 0; i < old_tree_length; i++ ) {
				new_T[i] = old_T[i];
			}
		}

		disp_node = & ( new_T[node_index] );

		// set the child value in the parent of the node being displaced
		parent_index = subTGetTreeIndex ( new_T, old_tree_length, disp_node->parent );
		disp_node_parent = & ( new_T[parent_index] );
		if ( disp_node_parent->Lchild == disp_node->value ) {
			disp_node_parent->Lchild = new_nonleaf_value;
		}
		else if ( disp_node_parent->Rchild == disp_node->value ) {
			disp_node_parent->Rchild = new_nonleaf_value;
		}
		else{exitOrException("\nerror adding image to tree");}

		// define the new nonleaf node
		new_nonleaf = & ( new_T[old_tree_length] );
		new_nonleaf->value = new_nonleaf_value;
		new_nonleaf->parent = disp_node_parent->value;
	}

	// set the new parent for the node we are displacing 
	disp_node->parent = new_nonleaf_value;

	// set the cut direction and pointers to children of the new nonleaf 
	new_nonleaf->cut_dir = cut_dir;
	new_nonleaf->Lchild  = disp_node->value;
	new_nonleaf->Rchild  = new_value;

	// at this point the new nonleaf node is ready, and the 
	// displaced node is appropriately modified ... but we still 
	// need to incorporate the other child of the new nonleaf node
}

int GEIDsAreEqual ( struct GE_identifier *GE1, struct GE_identifier *GE2 )
{
	if ( GE1->GA_index != GE2->GA_index ) return 0;
	if ( GE1->GE_index != GE2->GE_index ) return 0;

	return 1;
}

int GEIDsAreNotEqual ( struct GE_identifier *GE1, struct GE_identifier *GE2 )
{
	return ( 1 - GEIDsAreEqual ( GE1, GE2 ) );
}

int subTIDsAreEqual ( struct subT_identifier *subT1, struct subT_identifier *subT2 )
{
	if ( subT1->GA_index   != subT2->GA_index   ) return 0;
	if ( subT1->subT_index != subT2->subT_index ) return 0;

	return 1;
}

int subTIDsAreNotEqual ( struct subT_identifier *subT1, struct subT_identifier *subT2 )
{
	return ( 1 - subTIDsAreEqual ( subT1, subT2 ) );
}

int typeOfGA ( struct graphic_assembly *GA )
{
	if ( GA->type == PHOTO ) {
		return PHOTO;
	}

	if ( GA->type == PHOTO_GRP ) {
		return PHOTO_GRP;
	}

	if ( GA->type == PHOTO_VER ) {
		return PHOTO_VER;
	}

	if ( GA->type == FIXED_DIM ) {
		return FIXED_DIM;
	}

	if ( GA->type == PHOTO_SEQ ) {
		return PHOTO_SEQ;
	}

	exitOrException("\nerror determining graphic assembly type");

	return NO_TYPE;
}

int typeOfGASpec ( struct graphic_assembly_spec *GA_spec )
{
	if ( GA_spec->type == PHOTO ) {
		return PHOTO;
	}

	if ( GA_spec->type == PHOTO_GRP ) {
		return PHOTO_GRP;
	}

	if ( GA_spec->type == PHOTO_VER ) {
		return PHOTO_VER;
	}

	if ( GA_spec->type == FIXED_DIM ) {
		return FIXED_DIM;
	}

	if ( GA_spec->type == PHOTO_SEQ ) {
		return PHOTO_SEQ;
	}

	exitOrException("\nerror determining graphic assembly specification type");

	return NO_TYPE;
}

int oneGAHasMoreThanOnePresentation ( struct page_schedule *pg_sched,
									  struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;

	if ( pg_sched->num_GAs < 1 ) {
		exitOrException("\nerror determining whether one GA has more than one presentation");
	}

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( GA->num_subTs < 1 ) {
			exitOrException("\nerror determining whether one GA has more than one presentation");
		}

		if ( GA->num_subTs > 1 ) {
			return 1;
		}
	}

	return 0;
}

struct graphic_assembly *ithGAInPageSchedule ( struct page_schedule *pg_sched, int i, 
											   struct graphic_assembly_list *GA_list )
{
	int GA_index;
	struct page_schedule_entry *pse;

	if ( ( i < 0 ) || ( i >= pg_sched->num_GAs ) ) {
		exitOrException("\nerror getting i-th GA in page schedule");
	}

	pse = &( pg_sched->pse[i] );
	GA_index = pse->GA_index;

	if ( ( GA_index < 0 ) || ( GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\nerror getting i-th GA in page schedule");
	}
	return ( &( GA_list->GA[GA_index] ) );
}

struct photo *photoFromGEID ( struct GE_identifier *GE_ID,
							  struct graphic_assembly_list *GA_list )
{
	int i, photo_GA_index;
	struct graphic_assembly *GA, *photo_GA;
	struct photo *ph;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct photo_seq *ph_seq;

	GA = GAFromGEID ( GE_ID, GA_list );

	if ( typeOfGA ( GA ) == PHOTO ) {
		ph = &( GA->ph );
		if ( GEIDsAreEqual ( GE_ID, &( ph->GE_ID ) ) ) {
			return ( ph );
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		// the photo being asked for is part of a group;
		// the actual GA where the photo is described is elsewhere in the GA_list
		ph_grp = &( GA->ph_grp );
		for ( i = 0; i < ph_grp->num_photos; i++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
			if ( GEIDsAreEqual ( GE_ID, &( ph_grp_ph->GE_ID ) ) ) {
				photo_GA_index = ph_grp_ph->photo_GA_index;
				photo_GA = &( GA_list->GA[photo_GA_index] );
				if ( typeOfGA ( photo_GA ) != PHOTO ) {
					exitOrException("\nerror getting photo from GEID");
				}
				return ( &( photo_GA->ph ) );
			}
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		ph_ver = &( GA->ph_ver );

		for ( i = 0; i < ph_ver->num_versions; i++ ) {
			ph = &( ph_ver->photos[i] );
			if ( GEIDsAreEqual ( GE_ID, &( ph->GE_ID ) ) ) {
				return ( ph );
			}
		}
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		exitOrException("\nunable to retrieve photo from GA of type FIXED_DIM");
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		ph_seq = &( GA->ph_seq );

		for ( i = 0; i < ph_seq->num_photos; i++ ) {
			ph = &( ph_seq->photos[i] );
			if ( GEIDsAreEqual ( GE_ID, &( ph->GE_ID ) ) ) {
				return ( ph );
			}
		}
	}

	exitOrException("\nerror getting photo from GE_ID");

	return NULL;
}

struct fixed_dimensions_version *fixedDimensionsVersionFromGEID ( struct GE_identifier *GE_ID,
																  struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;

	GA = GAFromGEID ( GE_ID, GA_list );

	if ( typeOfGA ( GA ) == PHOTO ) {
		exitOrException("\nunable to retrieve fixed dimensions version from GA of type PHOTO");
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		exitOrException("\nunable to retrieve fixed dimensions version from GA of type PHOTO_GRP");
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		exitOrException("\nunable to retrieve fixed dimensions version from GA of type PHOTO_VER");
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		fd = &( GA->fd );

		for ( i = 0; i < fd->num_fd_versions; i++ ) {
			fd_ver = &( fd->fd_versions[i] );
			if ( GEIDsAreEqual ( GE_ID, &( fd_ver->GE_ID ) ) ) {
				return ( fd_ver );
			}
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		exitOrException("\nunable to retrieve fixed dimensions version from GA of type PHOTO_SEQ");
	}

	exitOrException("\nerror getting fixed dimensions version from GE_ID");

	return NULL;
}

struct graphic_assembly *GAFromGEID ( struct GE_identifier *GE_ID,
										 struct graphic_assembly_list *GA_list )
{
	int GA_index;
	struct graphic_assembly *GA;

	GA_index = GE_ID->GA_index;

	if ( ( GA_index < 0 ) || ( GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\nerror getting GA from GE_ID");
	}

	GA = &( GA_list->GA[GA_index] );

	if ( GA->GA_index != GE_ID->GA_index ) {
		exitOrException("\nerror getting GA from GE_ID");
	}

	return GA;
}


struct graphic_assembly *GAFromTreeValue ( struct subT_treeNode *T, int num_leaves, 
											int value, 
											struct graphic_assembly_list *GA_list )
{
	struct subT_identifier *subT_ID;
	int GA_index;
	struct graphic_assembly *GA;

	subT_ID = subTIDFromTreeValue ( T, num_leaves, value );
	GA_index = subT_ID->GA_index;

	if ( ( GA_index < 0 ) || ( GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\nGAFromTreeValue: invalid GA_index");
	}

	GA = &( GA_list->GA[GA_index] );

	return GA;
}


struct subT_identifier *subTIDFromTreeValue ( struct subT_treeNode *T,
											  int num_leaves, int value )
{
	int index;
	struct subT_identifier *subT_ID;

	if ( ( value < 1 ) || ( value > num_leaves ) ) {
		exitOrException("\nvalue does not correspond to a terminal node");
	}

	index = subTGetTreeIndex ( T, treeLen ( num_leaves ), value );
	subT_ID = &( T[index].subT_ID );

	return subT_ID;
}

int subTGetTreeIndex ( struct subT_treeNode *T, int tree_length, int value )
{
	int i, index, found;

	found = 0;
	for ( i = 0; i < tree_length; i++ ) {
		if ( T[i].value == value ) {
			index = i;
			found++;
		}
	}

	if ( found != 1 ) {
		exitOrException("\nerror finding tree index");
	}

	return index;
}

struct GE_treeNode *GETreeLeftChild ( struct GE_treeNode *GE_tree, struct GE_treeNode *node,
									  int num_GEs )
{
	int index;

	index = GEGetTreeIndex ( GE_tree, treeLen ( num_GEs ), node->Lchild );
	return ( &( GE_tree[index] ) );
}

struct GE_treeNode *GETreeRightChild ( struct GE_treeNode *GE_tree, struct GE_treeNode *node,
									   int num_GEs )
{
	int index;

	index = GEGetTreeIndex ( GE_tree, treeLen ( num_GEs ), node->Rchild );
	return ( &( GE_tree[index] ) );
}

struct GE_treeNode *GETreeParent ( struct GE_treeNode *GE_tree, struct GE_treeNode *node,
								   int num_GEs )
{
	int index;

	index = GEGetTreeIndex ( GE_tree, treeLen ( num_GEs ), node->parent );
	return ( &( GE_tree[index] ) );
}

struct GE_treeNode *GETreeNode ( struct GE_treeNode *GE_tree, int node_value,
								 int num_GEs )
{
	int index;

	index = GEGetTreeIndex ( GE_tree, treeLen ( num_GEs ), node_value );
	return ( &( GE_tree[index] ) );
}

int GEGetTreeIndex ( struct GE_treeNode *T, int tree_length, int value )
{
	int i, index, found;

	found = 0;
	for ( i = 0; i < tree_length; i++ ) {
		if ( T[i].value == value ) {
			index = i;
			found++;
		}
	}

	if ( found != 1 ) {
		exitOrException("\nerror finding tree index");
	}

	return index;
}


int treeValueFromSubTID ( struct subT_treeNode *T, int num_leaves, 
						  struct subT_identifier *subT_ID )
{
	int found, i, value;

	if ( num_leaves <= 0 ) {
		exitOrException("\nerror getting tree value from subT ID");
	}

	found = 0;
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		if ( T[i].value > 0 ) {
			if ( subTIDsAreEqual ( &(T[i].subT_ID), subT_ID ) ) {
				found++;
				value = T[i].value;
			}
		}
	}

	if ( found != 1 ) {
		exitOrException("\nfound more than one leaf node representing the same subT");
	}

	return value;
}

struct subT_treeNode *subTTreeNodeFromGAIndex ( struct pbook_page *page, int GA_index )
{
	int node_value, node_index;
	struct subT_treeNode *node;

	node_value = subTTreeValueFromGAIndex ( page->page_T, page->num_GAs, GA_index );
	node_index = subTGetTreeIndex ( page->page_T, treeLen ( page->num_GAs ), node_value );
	node = &( page->page_T[node_index] );

	return node;
}

struct subT_treeNode *subTTreeNodeFromTreeValue ( struct pbook_page *page, int node_value )
{
	int node_index;
	struct subT_treeNode *node;

	node_index = subTGetTreeIndex ( page->page_T, treeLen ( page->num_GAs ), node_value );
	node = &( page->page_T[node_index] );

	return node;
}

int subTTreeValueFromGAIndex ( struct subT_treeNode *T, int num_leaves, int GA_index )
{
	int found, i, value;

	if ( num_leaves <= 0 ) {
		exitOrException("\nerror getting tree value from subT ID");
	}

	found = 0;
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		if ( T[i].value > 0 ) {
			if ( T[i].subT_ID.GA_index == GA_index ) {
				found++;
				value = T[i].value;
			}
		}
	}

	if ( found != 1 ) {
		exitOrException("\nfound zero or more than one leaf nodes representing a GA");
	}

	return value;
}

struct GE_treeNode *GETreeNodeFromGAIndex ( struct GE_treeNode *GE_tree, 
											int num_leaves, int GA_index, 
											struct graphic_assembly_list *GA_list )
{
	int value;
	struct graphic_assembly *GA;
	struct GE_identifier GE_ID;

	GA = &( GA_list->GA[GA_index] );
//CBA
//	if ( typeOfGA ( GA ) != PHOTO ) {
//		exitOrException("\nunable to get GE_treeNode from GA_index ... GA must be of type PHOTO");
//	}
int i,count;
count=0;
for ( i = 0; i < treeLen ( num_leaves ); i++ ) 
{
	if ( GE_tree[i].GA_index == GA_index ) {
		if ( GE_tree[i].value > 0 ) {
			GE_ID = GE_tree[i].GE_ID;
			count++;
		}
	}
}
if(count!=1)exitOrException("\nerror getting ge treenode from ga index");


	// since this GA is of type PHOTO we know the GE_ID
//CBA
//	GE_ID.GA_index = GA_index;
//	GE_ID.GE_index = 0;
	value = GETreeValueFromGEID ( GE_tree, num_leaves, &GE_ID );

	return ( GETreeNode ( GE_tree, value, num_leaves ) );
}

int GETreeValueFromGEID ( struct GE_treeNode *T, int num_leaves, 
						  struct GE_identifier *GE_ID )
{
	int found, i, value;

	if ( num_leaves <= 0 ) {
		exitOrException("\nerror getting tree value from graphic element ID");
	}

	found = 0;
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		if ( T[i].value > 0 ) {
			if ( GEIDsAreEqual ( &(T[i].GE_ID), GE_ID ) ) {
				found++;
				value = T[i].value;
			}
		}
	}

	if ( found != 1 ) {
		exitOrException("\nfound more than one leaf node representing the same graphic element");
	}

	return value;
}


int treeIndexFromGEID ( struct GE_treeNode *T, int num_leaves, 
						 struct GE_identifier *GE_ID )
{
	int found, i, index;

	if ( num_leaves <= 0 ) {
		exitOrException("\nerror getting tree index from graphic element ID");
	}

	found = 0;
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		if ( T[i].value > 0 ) {
			if ( GEIDsAreEqual ( &(T[i].GE_ID), GE_ID ) ) {
				found++;
				index = i;
			}
		}
	}

	if ( found != 1 ) {
		exitOrException("\nexpected exactly one leaf having the desired graphic element ID");
	}

	return index;
}

void GEInitTree ( struct GE_treeNode *T, struct GE_identifier *GE_ID )
{
	// assign value 1 because all leaf nodes should have positive values;
	// since this is the root node, set the parent equal to the value
	T[0].value   = 1;
	T[0].parent  = 1;

	// assign graphic element to the leaf node
	T[0].GE_ID.GA_index = GE_ID->GA_index;
	T[0].GE_ID.GE_index = GE_ID->GE_index;
}

void subTInitTree ( struct subT_treeNode *T, struct subT_identifier *subT_ID )
{
	// assign value 1 because all leaf nodes should have positive values;
	// since this is the root node, set the parent equal to the value
	T[0].value   = 1;
	T[0].parent  = 1;

	// assign subT_D to the leaf node
	T[0].subT_ID = *subT_ID;
}

void GERemoveLeafFromTree ( struct GE_treeNode *T, int input_num_leaves,
						  struct GE_identifier *GE_ID )
{
	int tree_length, leaf_value, leaf_index;
	int parent_value, parent_index; 
	int sibling_value, sibling_index, grandparent_index, i;
	struct GE_treeNode *leaf_node, *parent_node, *sibling_node, *grandparent_node, *node;

	if ( input_num_leaves <= 0 ) {
		exitOrException("\ncan not remove an image from a tree with zero images");
	}

	// this routine does not decrement the number of leaves ... 
	// it assumes that will be taken care of in the calling routine

	// this routine operates on the tree array in-place -- it does not
	// modify the value of T (we do not delete [] the tree array, 
	// and we do not re-allocate it)

	if ( input_num_leaves == 1 ) {
		return;
	}

	// there are at least two leaves 
	//
	// we need to remove the leaf node and its parent
	//
	// the sibling of the leaf being removed will either 
	// (1) become a direct child of the "grandparent" or
	// (2) become the new root node (if the parent was root)

	tree_length = treeLen ( input_num_leaves );

	// identify the leaf that holds the graphical element
	leaf_value = GETreeValueFromGEID ( T, input_num_leaves, GE_ID );
	leaf_index = GEGetTreeIndex ( T, tree_length, leaf_value );
	leaf_node = & ( T[leaf_index] );

	// identify the parent
	parent_value = leaf_node->parent;
	parent_index = GEGetTreeIndex ( T, tree_length, parent_value );
	parent_node = & ( T[parent_index] );

	// identify the sibling
	if ( leaf_node->value == parent_node->Rchild ) {
		sibling_value = parent_node->Lchild;
	}
	else if ( leaf_node->value == parent_node->Lchild ) {
		sibling_value = parent_node->Rchild;
	}
	else { exitOrException("\nerror removing image from tree"); }
	sibling_index = GEGetTreeIndex ( T, tree_length, sibling_value );
	sibling_node = & ( T[sibling_index] );

	// set new references for the sibling 

	if ( parent_node->value == parent_node->parent ) {
		if ( parent_index != 0 ) {
			exitOrException("\nexpected root node to have index zero");
		}
		// the parent is the root ... so the sibling will become the new root
		sibling_node->parent = sibling_node->value;
	}
	else {
		// identify the grandparent node and couple it with the sibling
		grandparent_index = GEGetTreeIndex ( T, tree_length, parent_node->parent );
		grandparent_node = & ( T[grandparent_index] );
		sibling_node->parent = grandparent_node->value;
		if ( grandparent_node->Rchild == parent_node->value ) {
			grandparent_node->Rchild = sibling_node->value;
		}
		else if ( grandparent_node->Lchild == parent_node->value ) {
			grandparent_node->Lchild = sibling_node->value;
		}
		else { exitOrException("\nerror removing image from tree"); }
	}

	// copy the sibling into the place of the parent (in case the
	// former sibling is now a root node, we will want it to be moved
	// into the first position in the array); then shift the GE_treeNode 
	// array to occlude the old sibling GE_treeNode
	T[parent_index] = T[sibling_index];
	for ( i = sibling_index; i < tree_length - 1; i++ ) {
		T[i] = T[i+1];
	}
	tree_length--;

	// now shift the GE_treeNode array to occlude the leaf GE_treeNode
	if ( sibling_index < leaf_index ) {
		leaf_index--;
	}
	for ( i = leaf_index; i < tree_length - 1; i++ ) {
		T[i] = T[i+1];
	}
	tree_length--;

	// adjust references to node values, now that the values for the leaf 
	// and parent are vacant ... we can do it this way since leaf nodes 
	// have positive values and the nonleaf nodes have non-positive values
	if ( tree_length != treeLen ( input_num_leaves - 1 ) ) {
		exitOrException("\nerror removing leaf node from tree");
	}
	for ( i = 0; i < tree_length; i++ ) {
		node = & ( T[i] );

		// might as well verify that the leaf and parent values have been eradicated
		if ( ( node->value  == leaf_value )   || 
			 ( node->value  == parent_value ) || 
			 ( node->parent == leaf_value )   || 
			 ( node->parent == parent_value ) ) {
			exitOrException("\nerror removing leaf node from tree");
		}

		if ( node->value  > leaf_value   ) (node->value)--;
		if ( node->value  < parent_value ) (node->value)++;
		if ( node->parent > leaf_value   ) (node->parent)--;
		if ( node->parent < parent_value ) (node->parent)++;

		if ( ! ( node->value > 0 ) ) {
			if ( ( node->Rchild == leaf_value )	  || 
				 ( node->Rchild == parent_value ) || 
				 ( node->Lchild == leaf_value )	  || 
				 ( node->Lchild == parent_value ) ) {
				exitOrException("\nerror removing leaf node from tree");
			}

			if ( node->Rchild > leaf_value   ) (node->Rchild)--;
			if ( node->Rchild < parent_value ) (node->Rchild)++;
			if ( node->Lchild > leaf_value   ) (node->Lchild)--;
			if ( node->Lchild < parent_value ) (node->Lchild)++;
		}
	}
}


void subTRemoveLeafFromTree ( struct subT_treeNode **T, int input_num_leaves,
							  int GA_index )
{
	struct subT_treeNode *input_T, *node;
	struct subT_treeNode *leaf_node, *parent_node, *sibling_node, *grandparent_node;
	int tree_length, leaf_value, leaf_index;
	int parent_value, parent_index; 
	int sibling_value, sibling_index, grandparent_index, i;

	if ( input_num_leaves <= 0 ) {
		exitOrException("\ncan not remove a GA from a tree with zero GAs");
	}

	input_T = *T;

	if ( input_num_leaves == 1 ) {
		delete [] input_T;
		*T = NULL;
		return;
	}

	// there are at least two leaves 
	//
	// we need to remove the leaf node and its parent
	//
	// the sibling of the leaf being removed will either 
	// (1) become a direct child of the "grandparent" or
	// (2) become the new root node (if the parent was root)

	tree_length = treeLen ( input_num_leaves );

	// identify the leaf that holds the GA
	leaf_value = subTTreeValueFromGAIndex ( input_T, input_num_leaves, GA_index );
	leaf_index = subTGetTreeIndex ( input_T, tree_length, leaf_value );
	leaf_node = & ( input_T[leaf_index] );

	// identify the parent
	parent_value = leaf_node->parent;
	parent_index = subTGetTreeIndex ( input_T, tree_length, parent_value );
	parent_node = & ( input_T[parent_index] );

	// identify the sibling
	if ( leaf_node->value == parent_node->Rchild ) {
		sibling_value = parent_node->Lchild;
	}
	else if ( leaf_node->value == parent_node->Lchild ) {
		sibling_value = parent_node->Rchild;
	}
	else { exitOrException("\nerror removing GA from tree\n"); }
	sibling_index = subTGetTreeIndex ( input_T, tree_length, sibling_value );
	sibling_node = & ( input_T[sibling_index] );

	// set new references for the sibling 

	if ( parent_node->value == parent_node->parent ) {
		if ( parent_index != 0 ) {
			exitOrException("\nexpected root node to have index zero");
		}
		// the parent is the root ... so the sibling will become the new root
		sibling_node->parent = sibling_node->value;
	}
	else {
		// identify the grandparent node and couple it with the sibling
		grandparent_index = subTGetTreeIndex ( input_T, tree_length, parent_node->parent );
		grandparent_node = & ( input_T[grandparent_index] );
		sibling_node->parent = grandparent_node->value;
		if ( grandparent_node->Rchild == parent_node->value ) {
			grandparent_node->Rchild = sibling_node->value;
		}
		else if ( grandparent_node->Lchild == parent_node->value ) {
			grandparent_node->Lchild = sibling_node->value;
		}
		else { exitOrException("\nerror removing GA from tree\n"); }
	}

	// copy the sibling into the place of the parent (in case the
	// former sibling is now a root node, we will want it to be moved
	// into the first position in the array); then shift the subT_treeNode 
	// array to occlude the old sibling subT_treeNode
	input_T[parent_index] = input_T[sibling_index];
	for ( i = sibling_index; i < tree_length - 1; i++ ) {
		input_T[i] = input_T[i+1];
	}
	tree_length--;

	// now shift the subT_treeNode array to occlude the leaf subT_treeNode
	if ( sibling_index < leaf_index ) {
		leaf_index--;
	}
	for ( i = leaf_index; i < tree_length - 1; i++ ) {
		input_T[i] = input_T[i+1];
	}
	tree_length--;

	// adjust references to node values, now that the values for the leaf 
	// and parent are vacant ... we can do it this way since leaf nodes 
	// have positive values and the nonleaf nodes have non-positive values
	if ( tree_length != treeLen ( input_num_leaves - 1 ) ) {
		exitOrException("\nerror removing leaf node from tree");
	}
	for ( i = 0; i < tree_length; i++ ) {
		node = & ( input_T[i] );

		// might as well verify that the leaf and parent values have been eradicated
		if ( ( node->value  == leaf_value )   || 
			 ( node->value  == parent_value ) || 
			 ( node->parent == leaf_value )   || 
			 ( node->parent == parent_value ) ) {
			exitOrException("\nerror removing leaf node from tree");
		}

		if ( node->value  > leaf_value   ) (node->value)--;
		if ( node->value  < parent_value ) (node->value)++;
		if ( node->parent > leaf_value   ) (node->parent)--;
		if ( node->parent < parent_value ) (node->parent)++;

		if ( node->value <= 0 ) {
			if ( ( node->Rchild == leaf_value )	  || 
				 ( node->Rchild == parent_value ) || 
				 ( node->Lchild == leaf_value )	  || 
				 ( node->Lchild == parent_value ) ) {
				exitOrException("\nerror removing leaf node from tree");
			}

			if ( node->Rchild > leaf_value   ) (node->Rchild)--;
			if ( node->Rchild < parent_value ) (node->Rchild)++;
			if ( node->Lchild > leaf_value   ) (node->Lchild)--;
			if ( node->Lchild < parent_value ) (node->Lchild)++;
		}
	}
}


void GE_addLeafToTree ( struct GE_treeNode *old_T, struct GE_identifier *GE_ID, 
						struct GE_treeNode *new_T, 
						int old_num_leaves, int node_index, int cut_dir )
{
	int old_tree_length, new_leaf_value, new_nonleaf_value;
	struct GE_treeNode *new_leaf;

	// this routine assumes there is at least one leaf in old_T 
	// and that necessary space is already allocated in new_T
	//
	// (old_T may be the same as new_T)

	old_tree_length = treeLen ( old_num_leaves );

	// new leaf value is the next highest positive integer
	// new nonleaf value is the next lowest negative integer
	new_leaf_value = old_num_leaves + 1;
	new_nonleaf_value = 0 - ( new_leaf_value - 2 );

	GEAddNewNonleafNode ( old_T, old_tree_length, new_T, node_index,
						   new_nonleaf_value, cut_dir, new_leaf_value );

	// add the new leaf
	new_leaf = & ( new_T[old_tree_length+1] );
	new_leaf->value				= new_leaf_value;
	new_leaf->parent			= new_nonleaf_value;
	new_leaf->GE_ID.GA_index = GE_ID->GA_index;
	new_leaf->GE_ID.GE_index = GE_ID->GE_index;
}


void subTAddLeafToTree ( struct subT_treeNode *old_T, 
						 struct subT_identifier *subT_ID, 
						 struct subT_treeNode *new_T, 
						 int old_num_leaves, int node_index, int cut_dir )
{
	int old_tree_length, new_leaf_value, new_nonleaf_value;
	struct subT_treeNode *new_leaf;

	// this routine assumes there is at least one leaf in old_T 
	// and that necessary space is already allocated in new_T
	//
	// (old_T may be the same as new_T)

	// we could have made this routine reallocate the array for the new
	// tree and delete the old tree ... but usually this routine gets called
	// repeatedly from a single subroutine, and our thinking was, 
	// the memory handling was better managed by the routine that calls this one

	old_tree_length = treeLen ( old_num_leaves );

	// new leaf value is the next highest positive integer
	// new nonleaf value is the next lowest negative integer
	new_leaf_value = old_num_leaves + 1;
	new_nonleaf_value = 0 - ( new_leaf_value - 2 );

	subTAddNewNonleafNode ( old_T, old_tree_length, new_T, node_index,
							 new_nonleaf_value, cut_dir, new_leaf_value );

	// add the new leaf
	new_leaf = & ( new_T[old_tree_length+1] );
	new_leaf->value				 = new_leaf_value;
	new_leaf->parent			 = new_nonleaf_value;
	new_leaf->subT_ID.GA_index   = subT_ID->GA_index; 
	new_leaf->subT_ID.subT_index = subT_ID->subT_index;
}

int treeLen ( int num_term_nodes )
{
	if ( num_term_nodes <= 0 ) {
		exitOrException("\nerror determining tree length");
	}

	return ( ( 2 * num_term_nodes ) - 1 );
}

void GECopyTree ( struct GE_treeNode *from_T, struct GE_treeNode *to_T, int num_leaves )
{
	int i;

	if ( num_leaves > 0 ) {
		for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
			to_T[i] = from_T[i];
		}
	}
}

void subTCopyTree ( struct subT_treeNode *from_T, struct subT_treeNode *to_T, 
					int num_leaves )
{
	int i;

	// this routine assumes that if to_T already has an array allocated, 
	// then the array is sufficiently great in number of elements;
	// and if not, this routine allocates an array that is just big enough

	if ( to_T == NULL ) {
		if ( num_leaves > 0 ) {
			to_T = new struct subT_treeNode [ treeLen ( num_leaves ) ];
		}
	}

	if ( num_leaves > 0 ) {
		for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
			to_T[i] = from_T[i];
		}
	}
}


void printSubTTree ( struct subT_treeNode *subT_tree, int num_leaves )
{
	int i;

	printf("\nsubT tree:\n");
	printf("number of leaves: %d\n",num_leaves);
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		printf("value: %d\n",subT_tree[i].value);
		printf("parent: %d\n",subT_tree[i].parent);
		if ( subT_tree[i].value > 0 ) {
			printf("subT_ID: %d.%d\n", subT_tree[i].subT_ID.GA_index,
				   subT_tree[i].subT_ID.subT_index );
		}
		else {
			printf("Rchild: %d\n",subT_tree[i].Rchild);
			printf("Lchild: %d\n",subT_tree[i].Lchild);
			if ( subT_tree[i].cut_dir == HORIZ ) printf("HORIZ\n");
			else if ( subT_tree[i].cut_dir == VERT ) printf("VERT\n");
			else printf("error printing subT tree\n");
		}
		printf("\n");
	}
}

void printGETree ( struct GE_treeNode *GE_tree, int num_leaves )
{
	int i;

	printf("\nGE tree:\n");
	printf("number of leaves: %d\n",num_leaves);
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		printf("value: %d\n",GE_tree[i].value);
		printf("parent: %d\n",GE_tree[i].parent);
		if ( GE_tree[i].value > 0 ) {
			printf("GE_ID: %d.%d\n", GE_tree[i].GE_ID.GA_index,
				   GE_tree[i].GE_ID.GE_index );
		}
		else {
			printf("Lchild: %d\n",GE_tree[i].Lchild);
			printf("Rchild: %d\n",GE_tree[i].Rchild);
			if ( GE_tree[i].cut_dir == HORIZ ) printf("HORIZ\n");
			else if ( GE_tree[i].cut_dir == VERT ) printf("VERT\n");
			else printf("error printing GE tree\n");
		}
		printf("\n");
	}
}

void GETestTree ( struct config_params *cp, struct GE_treeNode *GE_tree, 
				   int num_leaves, int num_GAs )
{
	int value, index, parent_index, child_index, i; 
	struct GE_treeNode *node, *parent, *child, *R_child, *L_child;

	if ( num_leaves < 1 ) {
		exitOrException("\nto test tree require at least one terminal node");
	}

	for ( value = - ( num_leaves - 2 ); value <= num_leaves; value++ ) {
		// make sure this value is the value of exactly one node
		verifyValueIsUnique ( GE_tree, num_leaves, value );

		index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), value );
		node = &( GE_tree[index] );

		if ( node->value != node->parent ) {
			// this node is not the root ... 
			// verify its parent points to it as one of its children
			parent_index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->parent );
			parent = &( GE_tree[parent_index] );
			if ( ( parent->Lchild != value ) && ( parent->Rchild != value ) ) {
				exitOrException("\nnon-root node has parent that does not have it as a child");
			}
		}
		else {
			// this node is the root 
			//
			// verify that the index of this node is zero
			if ( index != 0 ) {
				exitOrException("\nexpected root node to appear at first node in array");
			}
		}

		if ( node->value < 1 ) {
			// node is not a leaf ... make sure its children are different 
			// and that both children point to the node as a parent
			if ( node->Rchild == node->Lchild ) {
				exitOrException("\nnode points to two children with the same value");
			}
			child_index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->Rchild );
			child = &( GE_tree[child_index] );
			if ( child->parent != value ) {
				exitOrException("\nright child of node does not have node as its parent");
			}
			child_index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->Lchild );
			child = &( GE_tree[child_index] );
			if ( child->parent != value ) {
				exitOrException("\nleft child of node does not have node as its parent");
			}

			// make sure the spacing for this node is not unexpected 
			checkSpacing ( cp, node->cut_spacing );
		}
	}

	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		node = &( GE_tree[i] );
		if ( ( node->GA_index < -1 ) || ( node->GA_index >= num_GAs ) ) {
			exitOrException("\nnode in GE_tree has invalid GA_index");
		}

		if ( node->value != node->parent ) {
			index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->parent );
			parent = &( GE_tree[index] );
		}
		if ( node->value < 1 ) {
			index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->Rchild );
			R_child = &( GE_tree[index] );
			index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->Lchild );
			L_child = &( GE_tree[index] );
		}

		if ( node->GA_index == -1 ) {
			if ( node->value > 0 ) {
				printf("leaf node on GE_tree has invalid GA_index\n");
			}
			if ( node->value != node->parent ) {
				if ( parent->GA_index != -1 ) {
					exitOrException("\ninvalid relationship between GA_indices of node and parent");
				}
			}
		}
		else {
			if ( node->value < 1 ) {
				if ( node->GA_index != R_child->GA_index ) {
					exitOrException("\nGA_indices of node and child on GE_tree do not match");
				}
				if ( R_child->GA_index != L_child->GA_index ) {
					exitOrException("\nGA_indices of subT siblings on GE_tree do not match");
				}
			}
		}
	}
}


static void checkSpacing ( struct config_params *cp, double spacing )
{
	if ( ( fabs ( spacing - ( cp->INTER_GA_SPACING ) ) > EPSILON ) &&
		 ( fabs ( spacing - ( cp->PHOTO_SEQ_SPACING ) ) > EPSILON ) && 
		 ( fabs ( spacing - ( cp->PHOTO_GRP_SPACING ) ) > EPSILON ) ) {
		exitOrException("\nunexpected spacing value in interior node of GE tree");
	}
}


static void verifyValueIsUnique ( struct GE_treeNode *GE_tree, int num_leaves,
								  int value )
{
	int i, count;

	count = 0;
	for ( i = 0; i < treeLen ( num_leaves ); i++ ) {
		if ( GE_tree[i].value == value ) count++;
	}

	if ( count != 1 ) {
		exitOrException("\nencountered a nonunique tree value");
	}
}

static struct page_schedule_entry *pageScheduleEntryFromGAIndex ( int GA_index,
																  struct page_schedule *pg_sched,
																  struct graphic_assembly_list *GA_list )
{
	int i, j, count, pse_GA_index;
	struct page_schedule_entry *pse, *soughtafter_pse;
	struct graphic_assembly *pse_GA;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;

	count = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );

		if ( GA_index == pse->GA_index ) {
			soughtafter_pse = pse;
			count++;
		}
	}

	if ( count == 1 ) {
		return ( soughtafter_pse );
	}

	if ( count > 1 ) {
		exitOrException("\nunable to get page schedule entry from page schedule using GA index");
	}

	// the input GA_index does not equal the GA_index 
	// of any page schedule entry in the page schedule
	//
	// another possibility is that the input GA_index identifies 
	// a photo that is part of a photo group, and the photo group appears
	// on the page schedule; troll through the page schedule
	// and see if any page schedule entry corresponds to the input GEID
	//
	// it may be up to the calling routine to verify the 
	// page schedule entry that is handed back, is the expected type
	count = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		pse_GA_index = pse->GA_index;
		pse_GA = &( GA_list->GA[pse_GA_index] );
		if ( typeOfGA ( pse_GA ) == PHOTO_GRP ) {
			ph_grp = &( pse_GA->ph_grp );
			for ( j = 0; j < ph_grp->num_photos; j++ ) {
				ph_grp_ph = &( ph_grp->photo_grp_photos[j] );
				if ( GA_index == ph_grp_ph->photo_GA_index  ) {
					soughtafter_pse = pse;
					count++;
				}
			}
		}
	}

	if ( count != 1 ) {
		exitOrException("\nunable to get page schedule entry from page schedule using GA index");
	}

	return ( soughtafter_pse );
}

struct graphic_element_schedule *GEScheduleFromGEID ( struct GE_identifier *GE_ID,
													  struct page_schedule *pg_sched,
													  struct graphic_assembly_list *GA_list )
{
	int i, j, count, GA_index;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched, *soughtafter_GE_sched;
	struct graphic_assembly *GA;
	struct GE_identifier *GE_sched_GEID, *corresponding_photo_GEID;

	pse = pageScheduleEntryFromGAIndex ( GE_ID->GA_index, pg_sched, GA_list );

	count = 0;
	for ( i = 0; i < pse->num_GEs; i++ ) {
		GE_sched = &( pse->GE_scheds[i] );

		if ( GEIDsAreEqual ( &( GE_sched->GE_ID ), GE_ID ) ) {
			soughtafter_GE_sched = GE_sched;
			count++;
		}
	}

	if ( count == 1 ) {
		return ( soughtafter_GE_sched );
	}

	if ( count > 1 ) {
		exitOrException("\nunable to get GE schedule from page schedule using GE_ID");
	}

	// the input GEID does not equal any GEID in the page schedule
	//
	// another possibility is that the input GEID identifies 
	// a photo that is part of a photo group, and the photo group appears
	// on the page schedule; troll through the page schedule
	// and see if any page schedule entry corresponds to the input GEID
	count = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );
		if ( typeOfGA ( GA ) == PHOTO_GRP ) {
			for ( j = 0; j < pse->num_GEs; j++ ) {
				GE_sched = &( pse->GE_scheds[j] );
				GE_sched_GEID = &( GE_sched->GE_ID );	// the GEID of a photo group photo
				corresponding_photo_GEID = photoGEIDFromPhotoGrpGEID ( GE_sched_GEID, GA_list );

				if ( GEIDsAreEqual ( GE_ID, corresponding_photo_GEID ) ) {
					soughtafter_GE_sched = GE_sched;
					count++;
				}
			}
		}
	}

	if ( count != 1 ) {
		exitOrException("\nunable to get GE schedule from page schedule using GE_ID");
	}

	return ( soughtafter_GE_sched );
}

double photoRelativeAreaFromGA ( struct graphic_assembly *GA, struct pbook_page *page,
								 struct graphic_assembly_list *GA_list )
{
	struct photo *ph;

	if ( typeOfGA ( GA ) != PHOTO ) {
		exitOrException("\nunable to get photo rel area from GA: GA not of type photo");
	}

	ph = &( GA->ph );
	return ( GERelativeArea ( &( ph->GE_ID ), &( page->sched ), GA_list ) );
}

double GERelativeArea ( struct GE_identifier *GE_ID, struct page_schedule *pg_sched,
						struct graphic_assembly_list *GA_list )
{
	double relative_area;
	struct graphic_element_schedule *GE_sched;

	GE_sched = GEScheduleFromGEID ( GE_ID, pg_sched, GA_list );

	relative_area = GE_sched->relative_area;

	if ( relative_area < 0.0 ) {
		exitOrException("\ninvalid photo relative area");
	}

	return ( relative_area );
}

double GETargetArea ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
					  struct graphic_assembly_list *GA_list )
{
	double target_area;
	struct graphic_element_schedule *GE_sched;

	GE_sched = GEScheduleFromGEID ( GEID, pg_sched, GA_list );

	target_area = GE_sched->target_area;

	if ( target_area < 0.0 ) {
		exitOrException("\ninvalid photo target area");
	}

	return ( target_area );
}

double GERelativeHeight ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
						  struct graphic_assembly_list *GA_list )
{
	return sqrt ( GERelativeArea ( GEID, pg_sched, GA_list ) * GEAspectFromGAList ( GEID, GA_list ) );
}

double GETargetHeight ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
						struct graphic_assembly_list *GA_list )
{
	return sqrt ( GETargetArea ( GEID, pg_sched, GA_list ) * GEAspectFromGAList ( GEID, GA_list ) );
}

double GERelativeWidth ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
						 struct graphic_assembly_list *GA_list )
{
	return sqrt ( GERelativeArea ( GEID, pg_sched, GA_list ) / GEAspectFromGAList ( GEID, GA_list ) );
}

double GETargetWidth ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
					   struct graphic_assembly_list *GA_list )
{
	return sqrt ( GETargetArea ( GEID, pg_sched, GA_list ) / GEAspectFromGAList ( GEID, GA_list ) );
}

int GAsAreSimilarPhotos ( struct config_params *cp,
						  struct graphic_assembly *GA1, struct graphic_assembly *GA2,
						  struct page_schedule *pg_sched,
						  struct graphic_assembly_list *GA_list )
{
	if ( ( GA1->type == PHOTO ) && ( GA2->type == PHOTO ) ) {
		if ( GEsAreSimilar ( cp, &( GA1->ph.GE_ID ), &( GA2->ph.GE_ID ), pg_sched, GA_list ) ) {
			return PASS;
		}
	}

	return FAIL;
}

static int GEsAreSimilar ( struct config_params *cp,
						   struct GE_identifier *GE_ID1, struct GE_identifier *GE_ID2,
						   struct page_schedule *pg_sched,
						   struct graphic_assembly_list *GA_list )
{
	double area_diff;

	// the aspect ratios must be equal
	if ( fabs ( GEAspectFromGAList ( GE_ID1, GA_list ) - GEAspectFromGAList ( GE_ID2, GA_list ) ) > EPSILON ) {
		return FAIL;
	}

	// and the relative areas must be equal
	area_diff = GERelativeArea ( GE_ID1, pg_sched, GA_list ) - GERelativeArea ( GE_ID2, pg_sched, GA_list );
	if ( fabs ( area_diff ) < EPSILON ) {
		return PASS;
	}

	return FAIL;
}

int GEsHaveFairlySimilarAspects ( struct GE_identifier *GEID1, struct GE_identifier *GEID2,
								  struct graphic_assembly_list *GA_list )
{
	double aspect1, aspect2, min_aspect, max_aspect, ratio_of_aspects; 

	aspect1 = GEAspectFromGAList ( GEID1, GA_list );
	aspect2 = GEAspectFromGAList ( GEID2, GA_list );

	// the aspect ratios must be close to each other
	if ( aspect1 < aspect2 ) {
		min_aspect = aspect1;
		max_aspect = aspect2;
	}
	else {
		min_aspect = aspect2;
		max_aspect = aspect1;
	}
	ratio_of_aspects = min_aspect / max_aspect;

	// sqrt ( ratio_of_aspects ) is equivalent to the area 
	// over which two rectangles of unit area but differing aspects 
	// do not overlap with each other
	if ( sqrt ( ratio_of_aspects ) < 0.95 ) {
		return FAIL;
	}

	return PASS;
}

double GEAspectFromGAList ( struct GE_identifier *GE_ID, struct graphic_assembly_list *GA_list )
{
	int pixel_height, pixel_width;
	double aspect, height, width;
	struct photo *ph;
	struct fixed_dimensions_version *fd_ver;
	struct pixel_rectangle *ROI, *crop_region;

	aspect = -1.0;
	if ( typeOfGE ( GE_ID, GA_list ) == PHOTO ) {
		ph = photoFromGEID ( GE_ID, GA_list );

		if ( ph->has_ROI ) {
			ROI = &( ph->ROI );
			pixel_height = ROI->height;
			pixel_width = ROI->width;
		}
		else if ( ph->has_crop_region ) {
			crop_region = &( ph->crop_region );
			pixel_height = crop_region->height;
			pixel_width = crop_region->width;
		}
		else {
			pixel_height = ph->height;
			pixel_width = ph->width;
		}

		if ( ( pixel_height <= 0 ) || ( pixel_width <= 0 ) ) {
			exitOrException("\ninvalid GE dimensions");
		}
		aspect = ((double)(pixel_height)) / ((double)(pixel_width));
	}
	else if ( typeOfGE ( GE_ID, GA_list ) == FIXED_DIM ) {
		fd_ver = fixedDimensionsVersionFromGEID ( GE_ID, GA_list );
		height = fd_ver->height;
		width = fd_ver->width;

		if ( ( height < EPSILON ) || ( width < EPSILON ) ) {
			exitOrException("\ninvalid GE dimensions");
		}
		aspect = height / width;
	}
	else {
		exitOrException("\nunable to get GE aspect from GA list");
	}

	if ( aspect < EPSILON ) {
		exitOrException("\nunable to get GE aspect from GA list");
	}

	return aspect;
}

void recordGEIDsInGASpec ( int GA_index, struct graphic_assembly_spec *GA_spec,
						   struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;

	struct photo *ph;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;
	struct photo_seq *ph_seq;

	struct photo_spec *ph_spec;
	struct photo_grp_spec *ph_grp_spec;
	struct photo_ver_spec *ph_ver_spec;
	struct fixed_dimensions_spec *fd_spec;
	struct fixed_dimensions_version_spec *fd_ver_spec;
	struct photo_seq_spec *ph_seq_spec;

	GA = &( GA_list->GA[GA_index] );

	if ( GA_spec->type != typeOfGA ( GA ) ) {
		exitOrException("\nunable to record GE_ID's in graphic assembly spec");
	}

	if ( typeOfGA ( GA ) == PHOTO ) {
		ph = &( GA->ph );
		ph_spec = &( GA_spec->ph_spec );

		ph_spec->GE_ID = ph->GE_ID;
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		ph_grp = &( GA->ph_grp );
		ph_grp_spec = &( GA_spec->ph_grp_spec );

		for ( i = 0; i < ph_grp->num_photos; i++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
			ph_spec = &( ph_grp_spec->ph_specs[i] );

			ph_spec->GE_ID = ph_grp_ph->GE_ID;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		ph_ver = &( GA->ph_ver );
		ph_ver_spec = &( GA_spec->ph_ver_spec );

		for ( i = 0; i < ph_ver->num_versions; i++ ) {
			ph = &( ph_ver->photos[i] );
			ph_spec = &( ph_ver_spec->ph_specs[i] );

			ph_spec->GE_ID = ph->GE_ID;
		}
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		fd = &( GA->fd );
		fd_spec = &( GA_spec->fd_spec );

		for ( i = 0; i < fd->num_fd_versions; i++ ) {
			fd_ver = &( fd->fd_versions[i] );
			fd_ver_spec = &( fd_spec->fd_version_specs[i] );

			fd_ver_spec->GE_ID = fd_ver->GE_ID;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		ph_seq = &( GA->ph_seq );
		ph_seq_spec = &( GA_spec->ph_seq_spec );

		for ( i = 0; i < ph_seq->num_photos; i++ ) {
			ph = &( ph_seq->photos[i] );
			ph_spec = &( ph_seq_spec->ph_specs[i] );

			ph_spec->GE_ID = ph->GE_ID;
		}
	}
	else {
		exitOrException("\nunable to record GE_ID's in graphic assembly spec");
	}
}

void assignGEIDs ( int GA_index, struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;
	struct photo *ph;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;
	struct photo_seq *ph_seq;

	GA = &( GA_list->GA[GA_index] );

	if ( GA->type == PHOTO ) {
		ph = &( GA->ph );
		ph->GE_ID.GA_index = GA->GA_index;
		ph->GE_ID.GE_index = 0;
	}
	else if ( GA->type == PHOTO_GRP ) {
		ph_grp = &( GA->ph_grp );
		for ( i = 0; i < ph_grp->num_photos; i++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
			ph_grp_ph->GE_ID.GA_index = GA->GA_index;
			ph_grp_ph->GE_ID.GE_index = i;
		}
	}
	else if ( GA->type == PHOTO_VER ) {
		ph_ver = &( GA->ph_ver );
		for ( i = 0; i < ph_ver->num_versions; i++ ) {
			ph = &( ph_ver->photos[i] );

			ph->GE_ID.GA_index = GA->GA_index;
			ph->GE_ID.GE_index = i;
		}
	}
	else if ( GA->type == FIXED_DIM ) {
		fd = &( GA->fd );
		for ( i = 0; i < fd->num_fd_versions; i++ ) {
			fd_ver = &( fd->fd_versions[i] );

			fd_ver->GE_ID.GA_index = GA->GA_index;
			fd_ver->GE_ID.GE_index = i;
		}
	}
	else if ( GA->type == PHOTO_SEQ ) {
		ph_seq = &( GA->ph_seq );
		for ( i = 0; i < ph_seq->num_photos; i++ ) {
			ph = &( ph_seq->photos[i] );

			ph->GE_ID.GA_index = GA->GA_index;
			ph->GE_ID.GE_index = i;
		}
	}
	else {
		exitOrException("\nerror assigning element identifiers");
	}
}

int numPhotoGrpArrangements ( )
{
	return ( 5 );
}

static void determineRowColConfigs ( struct photo_seq *ph_seq )
{
	int num_photos, count, i, j; 

	num_photos = ph_seq->num_photos;

	if ( num_photos <= 0 ) {
		exitOrException("\nunable to determine row-col configs for photo seq");
	}

	// count the number of pairs of integers whose products
	// equal the number of photos
	count = 0;
	for ( i = 1; i <= num_photos; i++ ) {
		for ( j = 1; j <= num_photos; j++ ) {
			if ( i * j == num_photos ) count++;
		}
	}
	if ( count <= 0 ) {
		exitOrException("\nerror factoring number of photos");
	}

	// record the integer pairs 
	ph_seq->num_rc_cfgs = count;
	ph_seq->rc_cfgs = new row_col_config [ ph_seq->num_rc_cfgs ];
	count = 0;
	for ( i = 1; i <= num_photos; i++ ) {
		for ( j = 1; j <= num_photos; j++ ) {
			if ( i * j == num_photos ) {
				ph_seq->rc_cfgs[count].num_rows = i;
				ph_seq->rc_cfgs[count].num_cols = j;
				count++;
			}
		}
	}

	if ( count != ph_seq->num_rc_cfgs ) {
		exitOrException("\nerror determining row-col configs for photo seq");
	}
}

void determineNum_subTs ( int GA_index, struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;
	struct photo_ver *ph_ver;
	struct fixed_dimensions *fd;
	struct photo_seq *ph_seq;

	GA = &( GA_list->GA[GA_index] );
	GA->num_subTs = 0;

	if ( typeOfGA ( GA ) == PHOTO ) {
		GA->num_subTs = 1;
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		GA->num_subTs = numPhotoGrpArrangements ( );
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		ph_ver = &( GA->ph_ver );
		GA->num_subTs = ph_ver->num_versions;
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		fd = &( GA->fd );
		GA->num_subTs = fd->num_fd_versions;
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		// the number of trees with only photos is the number of
		// pairs of integers whose products are the number of photos
		ph_seq = &( GA->ph_seq );
		determineRowColConfigs ( ph_seq );
		GA->num_subTs = ph_seq->num_rc_cfgs;
	}

	if ( GA->num_subTs <= 0 ) {
		exitOrException("\nerror counting the number of trees for a graphic assembly");
	}
}

int numVisibleGEs ( struct graphic_assembly *GA )
{
	// total number of graphic elements visible in any one instance of this GA

	int count = 0;

	if ( typeOfGA ( GA ) == PHOTO ) {
		count = 1;
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		count = GA->ph_grp.num_photos;
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		count = 1;
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		count = 1;
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		count = GA->ph_seq.num_photos;
	}

	if ( count <= 0 ) {
		exitOrException("\nerror counting graphic elements in graphic assembly");
	}

	// notice that count is positive

	return count;
}

void alloc_subTs ( int GA_index, struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;

	GA = &( GA_list->GA[GA_index] );

	if ( GA->num_subTs <= 0 ) {
		exitOrException("\nerror allocating trees for graphic assembly");
	}

	GA->subTs = new GE_treeNode * [ GA->num_subTs ];
	for ( i = 0; i < GA->num_subTs; i++ ) {
		GA->subTs[i] = new struct GE_treeNode [ treeLen ( numVisibleGEs ( GA ) ) ];
	}
}

static void verifyGA ( struct graphic_assembly *GA )
{
	if ( GA->num_subTs <= 0 ) {
		exitOrException("\ngraphic assembly should have positive number of subTs");
	}
}

void verifyPhotoGA ( struct graphic_assembly *GA )
{
	verifyGA ( GA );

	if ( GA->type != PHOTO ) {
		exitOrException("\ninvalid photo graphic assembly");
	}

	if ( GA->num_subTs != 1 ) {
		exitOrException("\ninvalid photo graphic assembly");
	}
}

void verifyPhotoGrpGA ( int GA_index, struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;
	struct photo_grp *ph_grp;

	GA = &( GA_list->GA[GA_index] );
	verifyGA ( GA );

	if ( GA->type != PHOTO_GRP ) {
		exitOrException("\ninvalid photo group graphic assembly");
	}

	ph_grp = & ( GA->ph_grp );

	if ( ph_grp->num_photos <= 0 ) {
		exitOrException("\ninvalid photo group graphic assembly");
	}

	if ( GA->num_subTs != numPhotoGrpArrangements ( ) ) {
		exitOrException("\ninvalid photo group graphic assembly");
	}
}

void copyIntegerList ( struct integer_list *from_list, struct integer_list *to_list )
{
	int i;

	// this routine assumes a sufficient array of integers 
	// has already been allocated in to_list 

	if ( from_list->num_integers < 0 ) {
		exitOrException ( "\nunable to copy integer list" );
	}

	for ( i = 0; i < from_list->num_integers; i++ ) {
		to_list->integers[i] = from_list->integers[i];
	}
	to_list->num_integers = from_list->num_integers;
}

void initIntegerList ( struct integer_list *list, int max_num_integers )
{
	if ( max_num_integers <= 0 ) {
		exitOrException("\nunable to initialize integer list - invalid max num of integers");
	}

	list->num_integers = 0;
	list->integers = new int [ max_num_integers ];
}

void initGEIDList ( struct GE_identifier_list *list, int max_GEIDs )
{
	if ( max_GEIDs <= 0 ) {
		exitOrException("\nunable to initialize GEID list - invalid max num of GEIDs");
	}

	list->num_GEIDs = 0;
	list->GEIDs = new struct GE_identifier [ max_GEIDs ];
}

void deleteIntegerList ( struct integer_list *list )
{
	// note, we do NOT check here whether num_integers is positive, 
	// since in initIntegerList, the array was allocated 
	// regardless of whether it would be used
	if ( list->integers != NULL ) {
		delete [] list->integers;
	}
}

void deleteGEIDList ( struct GE_identifier_list *list )
{
	// note, we do NOT check here whether num_GEIDs is positive, 
	// since in initGEIDList, the array was allocated 
	// regardless of whether it would be used
	if ( list->GEIDs != NULL ) {
		delete [] list->GEIDs;
	}
}

void initDoubleList ( struct double_list *list, int max_num_doubles )
{
	if ( max_num_doubles <= 0 ) {
		exitOrException("\nunable to initialize double list - invalid max num of doubles");
	}

	list->num_doubles = 0;
	list->doubles = new double [ max_num_doubles ];
}

void deleteDoubleList ( struct double_list *list )
{
	// note, we do NOT check here 
	// whether num_doubles is positive, 
	// since in initDoubleList,
	// the doubles array was allocated 
	// regardless of whether it would be used
	if ( list->doubles != NULL ) {
		delete [] list->doubles;
	}
}

struct GE_identifier *photoGrpGEIDFromPhotoGEID ( struct graphic_assembly *GA, 
												  struct GE_identifier *photo_GEID,
												  struct graphic_assembly_list *GA_list )
{
	int i, count, photo_GA_index;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct graphic_assembly *photo_GA;
	struct photo *ph;
	struct GE_identifier *photo_grp_GEID;

	// input is a GEID of a GA of type PHOTO; 
	// output is a GEID associated with a photo that is part of a photo group

	// the GA provided in function prototype must be of type PHOTO_GRP 
	if ( typeOfGA ( GA ) != PHOTO_GRP ) {
		exitOrException("\nunable to determine photo group GEID from photo GEID");
	}
	ph_grp = &( GA->ph_grp );

	count = 0;
	for ( i = 0; i < ph_grp->num_photos; i++ ) {
		ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
		photo_GA_index = ph_grp_ph->photo_GA_index;
		photo_GA = &( GA_list->GA[photo_GA_index] );

		if ( typeOfGA ( photo_GA ) != PHOTO ) {
			exitOrException("\nunable to determine photo group GEID from photo GEID");
		}
		ph = &( photo_GA->ph );

		if ( GEIDsAreEqual ( &( ph->GE_ID ), photo_GEID ) ) {
			count++;
			photo_grp_GEID = &( ph_grp_ph->GE_ID );
		}
	}

	if ( count != 1 ) {
		exitOrException("\nunable to determine photo group GEID from photo GEID");
	}

	return ( photo_grp_GEID );
}

struct photo *photoFromPhotoGrpGEID ( struct GE_identifier *photo_grp_GEID,
									  struct graphic_assembly_list *GA_list )
{
	struct GE_identifier *GE_ID;

	GE_ID = photoGEIDFromPhotoGrpGEID ( photo_grp_GEID, GA_list );
	return ( photoFromGEID ( GE_ID, GA_list ) );
}

struct GE_identifier *photoGEIDFromPhotoGrpGEID ( struct GE_identifier *photo_grp_GEID,
												  struct graphic_assembly_list *GA_list )
{
	int i, count, GA_index;
	struct graphic_assembly *GA;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct graphic_assembly *photo_GA;
	struct photo *ph;
	struct GE_identifier *photo_GEID;

	// input is a GEID associated with a photo that is part of a photo group
	// output is a GEID of a GA of type PHOTO; 

	GA_index = photo_grp_GEID->GA_index;
	GA = &( GA_list->GA[GA_index] );

	// the GA must be of type PHOTO_GRP 
	if ( typeOfGA ( GA ) != PHOTO_GRP ) {
		exitOrException("\nunable to determine photo GEID from photo group GEID");
	}
	ph_grp = &( GA->ph_grp );

	count = 0;
	for ( i = 0; i < ph_grp->num_photos; i++ ) {
		ph_grp_ph = &( ph_grp->photo_grp_photos[i] );

		if ( GEIDsAreEqual ( &( ph_grp_ph->GE_ID ), photo_grp_GEID ) ) {
			count++;

			GA_index = ph_grp_ph->photo_GA_index;
			photo_GA = &( GA_list->GA[GA_index] );
			if ( typeOfGA ( photo_GA ) != PHOTO ) {
				exitOrException("\nunable to determine photo GEID from photo group GEID");
			}
			ph = &( photo_GA->ph );
			photo_GEID = &( ph->GE_ID );
		}
	}

	if ( count != 1 ) {
		exitOrException("\nunable to determine photo GEID from photo group GEID");
	}

	return ( photo_GEID );
}

void verifyPhotoVerGA ( struct graphic_assembly *GA )
{
	struct photo_ver *ph_ver;

	verifyGA ( GA );

	if ( GA->type != PHOTO_VER ) {
		exitOrException("\ninvalid photo versions graphic assembly");
	}

	ph_ver = & ( GA->ph_ver );

	if ( ph_ver->num_versions <= 0 ) {
		exitOrException("\ninvalid photo versions graphic assembly");
	}

	if ( GA->num_subTs != ph_ver->num_versions ) {
		exitOrException("\ninvalid photo versions graphic assembly");
	}
}

void verifyFixedDimensionsGA ( struct graphic_assembly *GA )
{
	int i;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;

	verifyGA ( GA );

	if ( GA->type != FIXED_DIM ) {
		exitOrException("\ninvalid fixed dimensions graphic assembly");
	}

	fd = & ( GA->fd );

	if ( fd->num_fd_versions <= 0 ) {
		exitOrException("\ninvalid fixed dimensions graphic assembly");
	}

	if ( GA->num_subTs != fd->num_fd_versions ) {
		exitOrException("\ninvalid fixed dimensions graphic assembly");
	}

	for ( i = 0; i < fd->num_fd_versions; i++ ) {
		fd_ver = &( fd->fd_versions[i] );
		if ( ( fd_ver->height < EPSILON ) || ( fd_ver->width < EPSILON ) ) {
			exitOrException("\ninvalid fixed dimensions version dimensions");
		}
	}
}

void verifyPhotoSeqGA ( struct graphic_assembly *GA )
{
	struct photo_seq *ph_seq;

	verifyGA ( GA );

	if ( GA->type != PHOTO_SEQ ) {
		exitOrException("\ninvalid photo sequence graphic assembly");
	}

	ph_seq = & ( GA->ph_seq );

	if ( ph_seq->num_photos <= 0 ) {
		exitOrException("\ninvalid photo sequence graphic assembly");
	}

	if ( ph_seq->num_rc_cfgs <= 0 ) {
		exitOrException("\ninvalid photo sequence graphic assembly");
	}

	if ( GA->num_subTs != ph_seq->num_rc_cfgs ) {
		exitOrException("\ninvalid photo sequence graphic assembly");
	}
}

int typeOfGE ( struct GE_identifier *GE_ID, struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	struct graphic_assembly *GA;
	struct photo *ph;
	struct fixed_dimensions *fd;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct fixed_dimensions_version *fd_ver;
	struct photo_seq *ph_seq;

	GA_index = GE_ID->GA_index;
	GA = & ( GA_list->GA[GA_index] );

	if ( typeOfGA ( GA ) == PHOTO ) {
		ph = &( GA->ph );
		if ( GEIDsAreEqual ( &(ph->GE_ID), GE_ID ) ) return PHOTO;
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		ph_grp = &( GA->ph_grp );

		for ( i = 0; i < ph_grp->num_photos; i++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
			if ( GEIDsAreEqual ( &(ph_grp_ph->GE_ID), GE_ID ) ) return PHOTO;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		ph_ver = &( GA->ph_ver );

		for ( i = 0; i < ph_ver->num_versions; i++ ) {
			ph = &( ph_ver->photos[i] );
			if ( GEIDsAreEqual ( &(ph->GE_ID), GE_ID ) ) return PHOTO;
		}
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		fd = &( GA->fd );

		for ( i = 0; i < fd->num_fd_versions; i++ ) {
			fd_ver = &( fd->fd_versions[i] );
			if ( GEIDsAreEqual ( &(fd_ver->GE_ID), GE_ID ) ) return FIXED_DIM;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		ph_seq = &( GA->ph_seq );

		for ( i = 0; i < ph_seq->num_photos; i++ ) {
			ph = &( ph_seq->photos[i] );
			if ( GEIDsAreEqual ( &(ph->GE_ID), GE_ID ) ) return PHOTO;
		}
	}

	exitOrException("\nunable to identify type of graphic element");

	return NO_TYPE;
}

void setSublayoutSpacingValues ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list )
{
	int i, k;
	double spacing;
	struct graphic_assembly *GA;
	struct GE_treeNode *GE_tree;

	GA = &( GA_list->GA[GA_index] );

	for ( i = 0; i < GA->num_subTs; i++ ) {
		GE_tree = GA->subTs[i];

		for ( k = 0; k < treeLen ( numVisibleGEs ( GA ) ); k++ ) {
			if ( GE_tree[k].value <= 0 ) {
				// interior node ... set the spacing value 
				// in accordance with the GA type
				if ( typeOfGA ( GA ) == PHOTO_GRP ) {
					spacing = cp->PHOTO_GRP_SPACING;
				}
				else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
					spacing = cp->PHOTO_SEQ_SPACING;
				}
				else {
					exitOrException("\nerror setting sublayout spacing values");
				}

				GE_tree[k].cut_spacing = spacing;
			}

			// if this GE_treeNode is a leaf set the value of the border; 
			// otherwise zero out the value of the border
			GE_tree[k].border = 0.0;
			if ( GE_tree[k].value > 0 ) {
				GE_tree[k].border = cp->BORDER;
			}
		}
	}
}

void setGAIndices ( int GA_index, struct graphic_assembly_list *GA_list )
{
	int i, k;
	struct graphic_assembly *GA;
	struct GE_treeNode *GE_tree;

	GA = &( GA_list->GA[GA_index] );

	for ( i = 0; i < GA->num_subTs; i++ ) {
		GE_tree = GA->subTs[i];

		for ( k = 0; k < treeLen ( numVisibleGEs ( GA ) ); k++ ) {
			GE_tree[k].GA_index = GA->GA_index;
		}
	}
}

